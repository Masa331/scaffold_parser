module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        attr_reader :xsd

        def self.call(xsd, options)
          self.new(xsd, options).call
        end

        def initialize(xsd, options)
          @xsd = xsd
          @options = options
        end

        def call
          original_complex_types = xsd.schema.elements + xsd.schema.complex_types + xsd.schema.simple_types

          collect_only = -> (e) { ['schema', 'document', 'element', 'extension', 'complexType', 'simpleType', 'include', 'import'].include?(e.name) }
          included_schemas = xsd.schema.collect_included_schemas({ collect_only: collect_only })
          included_complex_types = included_schemas.inject([]) do |memo, schema|
            memo + schema.elements + schema.complex_types + schema.simple_types
          end

          imported_schemas = xsd.schema.collect_imported_schemas({ collect_only: collect_only })
          imported_complex_types = imported_schemas.inject([]) do |memo, schema|
            memo + schema.children
            memo + schema.elements + schema.complex_types + schema.simple_types
          end

          complex_types = normalize_complex_types(original_complex_types + included_complex_types + imported_complex_types)

          classes = complex_types.map do |complex_type|
            scaffold_class(complex_type)
          end

          same_classes = classes.group_by(&:name).select { |k, v| v.size > 1}
          if same_classes.any?
            fail 'multiple classes with same name'
          end

          classes.flat_map do |class_template|
            [["parsers/#{class_template.name.underscore}.rb", class_template.to_s],
             ["builders/#{class_template.name.underscore}.rb", class_template.to_builder_s],
             ["parsers/base_parser.rb", base_parser_template],
             ["builders/base_builder.rb", base_builder_template],
             ["requires.rb", create_requires_template(classes)]
            ]
          end
        end

        def normalize_complex_types(complex_types)
          result0 = remove_elements_from_root(complex_types)

          result1 = normalize_extensions(result0)
          result2 = remove_empty_complex_types(result1)

          result3 = remove_simple_types(result2)

          result4 = prepare_unbounded_elements(result3)
          result5 = extract_anonymous_complex_types(result4, result4.map(&:name))
          result6 = remove_basic_xsd_types(result5)

          result6
        end

        def remove_elements_from_root(complex_types)
          complex_types.map do |complex_type|
            if complex_type.is_a?(XsdModel::Elements::Element)

              child = complex_type.children.first
              if child.nil?
              require 'pry'; binding.pry
              end
              child.attributes = complex_type.attributes
              child.namespaces = complex_type.namespaces

              child
            else
              complex_type
            end
          end
        end

        def extract_anonymous_complex_types(complex_types, names)
          complex_types.each do |complex_type|
            complex_type.traverse do |node|
              if node.no_type? && node.children.last.is_a?(XsdModel::Elements::ComplexType) && node.children.last.no_type?
                new_node = node.children.pop
                name = node.name
                new_node.attributes['name'] = name
                node.attributes['type'] = name

                if complex_types.include? new_node
                  node.attributes['type'] = new_node.name
                elsif names.include? new_node.name

                  counter = 1
                  begin
                    counter += 1
                    candidate = "#{name}#{counter}"
                  end while names.include? candidate

                  names << candidate
                  new_node.attributes['name'] = candidate
                  node.attributes['type'] = candidate

                  complex_types += extract_anonymous_complex_types([new_node], names)
                else
                  name = node.name

                  new_node.attributes['name'] = name
                  node.attributes['type'] = name

                  names << name

                  complex_types += extract_anonymous_complex_types([new_node], names)
                end
              end
            end

            complex_type
          end

          complex_types
        end

        def remove_simple_types(complex_types)
          extracted = []

          normalized, extracted = complex_types.partition do |type|
            type.is_a? XsdModel::Elements::ComplexType
          end

          normalized = normalized.map do |complex_type|
            complex_type.traverse do |node|
              if node.children.last.is_a?(XsdModel::Elements::SimpleType)
                if node.children.last.has_name?
                  extracted << node.children.last
                end

                node.children = []
              end
            end

            complex_type
          end

          normalized = normalized.map do |complex_type|
            complex_type.traverse do |node|
              if extracted.map(&:name).include?(node.type)
                node.attributes.delete 'type'
              end
            end

            complex_type
          end
          normalized
        end

        def remove_empty_complex_types(complex_types)
          normalized = complex_types.map do |complex_type|
            complex_type.traverse do |node|
              if node.no_type?  && node.children.last.is_a?(XsdModel::Elements::ComplexType) && node.children.last.empty?  && node.children.last.base.nil?

                node.children = []
              end
            end

            complex_type
          end
        end

        def normalize_extensions(complex_types)
          complex_types.map do |complex_type|
            complex_type.traverse do |node|
              if node.children.last.is_a?(XsdModel::Elements::Extension)
                if node.children.last.basic_xsd_extension?
                  node.children = []
                else
                  node.attributes['base'] = node.children.last.base
                  node.children = node.children.last.children
                end
              end
            end

            complex_type
          end
        end

        def remove_basic_xsd_types(complex_types)
          complex_types.map do |complex_type|
            complex_type.traverse do |node|
              if node.basic_xsd_type?
                node.attributes.delete 'type'
              end
            end

            complex_type
          end
        end

        def prepare_unbounded_elements(complex_types)
          complex_types.map do |complex_type|
            complex_type.traverse do |node|
              if node.no_type? && node.children.last.is_a?(XsdModel::Elements::ComplexType) && node.children.last.no_type? && node.children.last.children.size == 1 && node.children.last.children.last.multiple? && !node.children.last.has_base?
                unbounded_element = node.children.last.children.last

                node.children = [unbounded_element]
              end
            end

            complex_type
          end
        end

        def scaffold_class(complex_type)
          methods = complex_type.elements.map do |element|
            if element.somehow_multiple?
              if element.multiple_proxy?
                ProxyListMethodTemplate.new(element)
              else
                ListMethodTemplate.new(element)
              end
            elsif element.has_type?
              SubmodelMethodTemplate.new(element)
            else
              AtMethodTemplate.new(element)
            end
          end

          template = ClassTemplate.new(complex_type.name.camelize) do |template|
            template.namespace = @options[:namespace]
            template.methods = methods

            if complex_type.has_base?
              template.inherit_from = complex_type.base.camelize
            end
          end
        end

        def base_parser_template
          <<~TEMPLATE
          module Parsers
            module BaseParser
              EMPTY_ARRAY = []

              attr_accessor :raw

              def initialize(raw)
                @raw = raw
              end

              def attributes
                raw.attributes
              end

              private

              def at(locator)
                return nil if raw.nil?

                element = raw.locate(locator.to_s).first

                if element
                  StringWithAttributes.new(element.text, element.attributes)
                end
              end

              def has?(locator)
                raw.locate(locator).any?
              end

              def submodel_at(klass, locator)
                element_xml = raw.locate(locator).first

                klass.new(element_xml) if element_xml
              end

              def array_of_at(klass, locator)
                return EMPTY_ARRAY if raw.nil?

                elements = raw.locate([*locator].join('/'))

                elements.map do |element|
                  klass.new(element)
                end
              end
            end
          end
          TEMPLATE
        end

        def base_builder_template
          <<~TEMPLATE
          module Builders
            module BaseBuilder
              attr_accessor :name, :data

              def initialize(name, data = {})
                @name = name
                @data = data || {}
              end

              def to_xml
                doc = Ox::Document.new(version: '1.0')
                doc << builder

                Ox.dump(doc, with_xml: true)
              end

              def build_element(name, content)
                element = Ox::Element.new(name)
                if content.respond_to? :attributes
                  content.attributes.each { |k, v| element[k] = v }
                end

                if content.respond_to? :value
                  element << content.value if content.value
                else
                  element << content if content
                end
                element
              end
            end
          end
          TEMPLATE
        end

        def create_requires_template(classes)
          with_inheritance, others = classes.partition { |klass| klass.inherit_from }

          requires = []
          others.each do |klass|
            requires << "parsers/#{klass.name.underscore}"
            requires << "builders/#{klass.name.underscore}"
          end
          with_inheritance.each do |klass|
            requires << "parsers/#{klass.name.underscore}"
            requires << "builders/#{klass.name.underscore}"
          end
          requires.unshift('parsers/base_parser')
          requires.unshift('builders/base_builder')

          if @options[:namespace]
            requires = requires.map { |r| r.prepend("#{@options[:namespace].underscore}/") }
          end

          requires = requires.map { |r| "require '#{r}'" }

          requires.join("\n")
        end
      end
    end
  end
end
