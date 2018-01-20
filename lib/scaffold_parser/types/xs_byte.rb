module ScaffoldParser
  module Types
    class XsByte
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
