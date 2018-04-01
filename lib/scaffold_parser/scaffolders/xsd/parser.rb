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
          original_complex_types = xsd.schema.complex_types

          collect_only = -> (e) { ['schema', 'document', 'element', 'extension', 'complexType', 'simpleType', 'include'].include?(e.name) }
          included_schemas = xsd.schema.collect_included_schemas({ collect_only: collect_only })
          included_complex_types = included_schemas.inject([]) do |memo, schema|
            memo + schema.complex_types + schema.simple_types
          end

          imported_schemas = xsd.schema.collect_imported_schemas({ collect_only: collect_only })
          imported_complex_types = imported_schemas.inject([]) do |memo, schema|
            memo + schema.complex_types + schema.simple_types
          end

          complex_types = normalize_complex_types(original_complex_types + included_complex_types)

          classes = complex_types.map do |complex_type|
            scaffold_class(complex_type)
          end

          if classes.group_by(&:name).values.any? { |v| v.size > 1 }
            fail 'multiple classes with same name'
          end

          classes.flat_map do |class_template|
            [["parsers/#{class_template.name.underscore}.rb", class_template.to_s],
             ["builders/#{class_template.name.underscore}.rb", class_template.to_builder_s]
            ]
          end
        end

        def normalize_complex_types(complex_types)
          result = normalize_extensions(complex_types)
          result = remove_empty_complex_types(result)

          result = remove_simple_types(result)

          result = prepare_unbounded_elements(result)
          result = extract_anonymous_complex_types(result, result.map(&:name))
          result = remove_basic_xsd_types(result)

          result
        end

        def extract_anonymous_complex_types(complex_types)
          extracted = []

          normalized = complex_types.map do |complex_type|
            complex_type.traverse do |node|
              if node.no_type? && node.children.last.is_a?(XsdModel::Elements::ComplexType) && node.children.last.no_type?
                new_node = node.children.pop
                name = node.name

                new_node.attributes['name'] = name
                node.attributes['type'] = name
                extracted = extracted + extract_anonymous_complex_types([new_node])
              end
            end

            complex_type
          end

          normalized + extracted
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
              if node.no_type? && node.children.last.is_a?(XsdModel::Elements::ComplexType) && node.children.last.empty?
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
      end
    end
  end
end
