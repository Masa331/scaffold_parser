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
        Parser.call(@doc, @options) + Builder.call(@doc, @options)
      end
    end
  end
end
