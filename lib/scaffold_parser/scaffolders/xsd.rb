# require 'scaffold_parser/scaffolders/xsd/reactor_parser'
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
        code = Parser.call(@doc, @options)

        code
      end
    end
  end
end
