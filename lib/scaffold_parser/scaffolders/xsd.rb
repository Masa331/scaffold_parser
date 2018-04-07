require 'scaffold_parser/scaffolders/xsd/parser'

module ScaffoldParser
  module Scaffolders
    class XSD
      def self.call(doc, options)
        self.new(doc, options).call
      end

      def initialize(doc, options)
        @doc = doc
        @options = options
      end

      def call
        classes = Parser.call(@doc)

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
