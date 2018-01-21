require 'scaffold_parser/types/base_type'

module ScaffoldParser
  module Types
    class Choice < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        @schema.children.flat_map do |element|
          TypeClassResolver.call(element)
        end.compact
      end
    end
  end
end
