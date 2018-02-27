require 'scaffold_parser/scaffolders/xsd/parser'
require 'scaffold_parser/scaffolders/xsd/builder'

module ScaffoldParser
  module Scaffolders
    class XSD
      def self.call(doc, options, already_scaffolded_subelements = [])
        self.new(doc, options, already_scaffolded_subelements).call
      end

      def initialize(doc, options, already_scaffolded_subelements)
        @doc = doc
        @options = options
        @already_scaffolded_subelements = already_scaffolded_subelements
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

        unscaffolded_subelements.each do |subelement|
          @already_scaffolded_subelements << subelement.to_class_name

          Parser.call(subelement.definition, @options)
          Builder.call(subelement.definition, @options)
          self.class.call(subelement.definition, @options, @already_scaffolded_subelements)
        end
      end

      private

      def unscaffolded_subelements
        all = @doc.submodel_nodes.to_a + @doc.array_nodes.map(&:list_element)

        all
          .reject(&:xs_type?)
          .reject { |node| @already_scaffolded_subelements.include?(node.to_class_name) }
      end
    end
  end
end
