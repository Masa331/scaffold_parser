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

        unless Dir.exists?('./tmp/builders')
          Dir.mkdir('./tmp/builders')
          puts './tmp/builders directory created'
        end

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
    end
  end
end
