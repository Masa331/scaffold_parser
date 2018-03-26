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
        puts "Starting collectiong elements to scaffold" if @options[:verbose]

        unscaffolded_elements = collect_unscaffolded_subelements(@doc) + @doc.submodel_nodes

        puts "Collected #{unscaffolded_elements.size} elements to scaffold" if @options[:verbose]

        code = unscaffolded_elements.flat_map do |element|
          [Parser.call(element.definition, @options), Builder.call(element.definition, @options)]
        end

        code.push ['parsers/base_parser.rb', base_parser_template]
        code.push ['builders/base_builder.rb', base_builder_template]
      end

      private

      def collect_unscaffolded_subelements(node, collected = [])
        subelements = node.definition.submodel_nodes.to_a + node.definition.array_nodes.map(&:list_element)
          .reject(&:xs_type?)
          .reject { |node| collected.include?(node.to_class_name) }

        subelements.each do |element|
          if collected.none? { |c| c.to_class_name == element.to_class_name }
            collected << element

            puts "Collected #{element.to_name} element" if @options[:verbose]

            collect_unscaffolded_subelements(element, collected)
          end
        end

        collected
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
