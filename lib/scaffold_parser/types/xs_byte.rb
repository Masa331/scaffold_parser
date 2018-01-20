require 'scaffold_parser/types/base_type'

module ScaffoldParser
  module Types
    class XsByte < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        node = Node.new
        node.name = @schema['name']
        node
      end
    end
  end
end
