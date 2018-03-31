require 'scaffold_parser/scaffolders/xsd/parser'
require 'scaffold_parser/scaffolders/xsd/builder'

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
        elements = collect_elements(@doc)

        code = []

        elements.each do |element|
          if element.is_a? XsdModel::Elements::ComplexType
            name = element.name.camelize
            node = element
            extension = nil
            options = @options
          elsif element.is_a? XsdModel::Elements::Element
            name = element.name.camelize
            node = element
            extension = nil
            options = @options
          end

          # code.push Parser.call(name, node, extension, options)
          code.push ReactorParser.call(name, node, extension, options)
          # code.push Builder.call(element, @options)
        end

        code.push ['parsers/base_parser.rb', base_parser_template]
        code.push ['builders/base_builder.rb', base_builder_template]
      end

      private

      def collect_elements(doc)
        doc.traverse.select do |child|
          (child.is_a?(XsdModel::Elements::ComplexType) && child.name) ||
            (child.is_a?(XsdModel::Elements::Element) && child.children.last.is_a?(XsdModel::Elements::Element))
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
    end
  end
end
