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
        unless Dir.exists?('./tmp/')
          Dir.mkdir('./tmp/')
          puts './tmp/ directory created'
        end
        File.open('./tmp/base_element.rb', 'wb') { |f| f.write base_element_template }

        unless Dir.exists?('./tmp/builders')
          Dir.mkdir('./tmp/builders')
          puts './tmp/builders directory created'
        end
        File.open('./tmp/builders/base_builder.rb', 'wb') { |f| f.write base_builder_template }

        unscaffolded_elements = collect_unscaffolded_subelements(@doc) + @doc.submodel_nodes

        unscaffolded_elements.each do |element|
          Parser.call(element.definition, @options)
          Builder.call(element.definition, @options)
        end
      end

      private

      def collect_unscaffolded_subelements(node, collected = [])
        subelements = node.submodel_nodes.to_a + node.array_nodes.map(&:list_element)
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
                Ox.dump(builder)
              end
            end
          end
        TEMPLATE
      end
    end
  end
end
