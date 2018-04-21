require 'scaffold_parser/scaffolders/xsd/parser'
require 'scaffold_parser/scaffolders/xsd/parser/templates/utils'

module ScaffoldParser
  module Scaffolders
    class XSD
      include Parser::Templates::Utils

      def self.call(doc, options, parse_options = {})
        self.new(doc, options, parse_options).call
      end

      def initialize(doc, options, parse_options = {})
        @doc = doc
        @options = options
        @parse_options = parse_options
      end

      def call
        all = [@doc.schema] + @doc.schema.collect_included_schemas(@parse_options) + @doc.schema.collect_imported_schemas(@parse_options)

        all_classes = Parser.call(all, @options)

        simple_types, classes = all_classes.partition do |klass|
          klass.is_a? Parser::Templates::SimpleTypeKlass
        end

        #TODO: get rid of this. SimpleType elements handling
        classes.each do |klass|
          klass.methods = klass.methods.map do |meth|
            if meth.is_a?(Parser::Templates::SubmodelMethod) && simple_types.map(&:name).include?(meth.submodel_class)
              meth.to_at_method
            else
              meth
            end
          end
        end

        classes.each do |klass|
          klass.namespace = @options.fetch(:namespace, nil)
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

      private

      def base_parser_template
        template =
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

        if @options.fetch(:namespace, nil)
          wrap_in_namespace(template, @options[:namespace])
        else
          template
        end
      end

      def base_builder_template
        template =
          <<~TEMPLATE
            module Builders
              module BaseBuilder
                attr_accessor :name, :data, :options

                def initialize(name, data = {}, options = {})
                  @name = name
                  @data = data || {}
                  @options = options || {}
                end

                def to_xml
                  encoding = options[:encoding]

                  doc_options = { version: '1.0' }
                  doc_options[:encoding] = encoding if encoding
                  doc = Ox::Document.new(doc_options)
                  doc << builder

                  dump_options = { with_xml: true }
                  dump_options[:encoding] = encoding if encoding
                  Ox.dump(doc, dump_options)
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

        if @options.fetch(:namespace, nil)
          wrap_in_namespace(template, @options[:namespace])
        else
          template
        end
      end

      def create_requires_template(classes)
        modules = classes.select { |cl| cl.is_a? Parser::Templates::Module }
        classes = classes.reject { |cl| cl.is_a? Parser::Templates::Module }
        with_inheritance, others = classes.partition { |klass| klass.inherit_from }

        requires = []
        modules.each do |klass|
          requires << "parsers/#{klass.name.underscore}"
          requires << "builders/#{klass.name.underscore}"
        end
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
