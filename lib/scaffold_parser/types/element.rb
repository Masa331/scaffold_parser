module ScaffoldParser
  module Types
    class Element
      def initialize(schema)
        @schema = schema
      end

      def call
        children = @schema.children.flat_map do |element|
          type_class = TypeClassResolver.call(element)

          type_class.new(element).call
        end.compact

        node = Node.new
        node.name = @schema['name']
        children.each { |c| node.nodes << c }
        node
      end
    end
  end
end
