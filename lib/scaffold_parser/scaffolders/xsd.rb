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
        unscaffolded_elements = collect_unscaffolded_subelements(@doc) + @doc.submodel_nodes

        code = unscaffolded_elements.flat_map do |element|
          [Parser.call(element.definition, @options), Builder.call(element.definition, @options)]
        end

        code.push ['./tmp/base_element.rb', base_element_template]
        code.push ['./tmp/builders directory created', base_builder_template]
      end

      private

      def collect_unscaffolded_subelements(node, collected = [])
        subelements = node.definition.submodel_nodes.to_a + node.definition.array_nodes.map(&:list_element)
          .reject(&:xs_type?)
          .reject { |node| collected.include?(node.to_class_name) }

        subelements.each do |element|
          if collected.none? { |c| c.to_class_name == element.to_class_name }
            collected << element
            collect_unscaffolded_subelements(element, collected)
          end
        end

        collected
      end

      def base_element_template
        <<~TEMPLATE
          module BaseElement
            EMPTY_ARRAY = []

            attr_accessor :raw

            def initialize(raw)
              @raw = raw
            end

            private

            def at(locator)
              return nil if raw.nil?

              raw[locator]
            end

            def submodel_at(klass, locator)
              element_xml = at locator

              klass.new(element_xml) if element_xml
            end

            def array_of_at(klass, locator)
              return EMPTY_ARRAY if raw.nil?

              elements = raw.dig(*locator) || EMPTY_ARRAY
              if elements.is_a?(Hash) || elements.is_a?(String)
                elements = [elements]
              end

              elements.map do |raw|
                klass.new(raw)
              end
            end

            def all(locator)
              return EMPTY_ARRAY if raw.nil?

              result = raw[locator]

              if result.is_a? Hash
                [result]
              elsif result.is_a? Array
                result
              else
                EMPTY_ARRAY
              end
            end
          end
        TEMPLATE
      end

      def base_builder_template
        <<~TEMPLATE
          module Builders
            module BaseBuilder
              def initialize(attributes = {})
                attributes ||= {}
                attributes.each do |key, value|
                  send("\#{key}=", value)
                end
              end

              def to_xml
                doc = Ox::Document.new
                doc << builder

                Ox.dump(doc, with_xml: true)
              end
            end
          end
        TEMPLATE
      end
    end
  end
end
