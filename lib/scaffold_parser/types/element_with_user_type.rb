module ScaffoldParser
  module Types
    class ElementWithUserType < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        node = Node.new
        node.name = @schema['name']
        node.type = @schema['type']
        node
      end
    end
  end
end
