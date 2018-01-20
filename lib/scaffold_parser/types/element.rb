module ScaffoldParser
  module Types
    class Element < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        children = @schema.children.flat_map do |element|
          TypeClassResolver.call(element)
        end.compact

        node = Node.new
        node.name = @schema['name']
        children.each { |c| node.nodes << c }
        node
      end
    end
  end
end
