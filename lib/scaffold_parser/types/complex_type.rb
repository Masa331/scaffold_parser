module ScaffoldParser
  module Types
    class ComplexType
      def initialize(schema)
        @schema = schema
      end

      def call
        if @schema['name'].present?
          children = @schema.children.flat_map do |child|
            type_class = TypeClassResolver.call(child)

            type_class.new(child).call
          end.compact

          node = Node.new
          node.name = @schema['name']
          children.each { |c| node.nodes << c }
          node
        else
          @schema.children.flat_map do |child|
            type_class = TypeClassResolver.call(child)

            type_class.new(child).call
          end.compact
        end
      end
    end
  end
end
