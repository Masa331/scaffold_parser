module ScaffoldParser
  module Types
    class ComplexType < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        if @schema['name'].present?
          children = @schema.children.flat_map do |child|
            TypeClassResolver.call(child)
          end.compact

          node = Node.new
          node.name = @schema['name']
          children.each { |c| node.nodes << c }
          node
        else
          @schema.children.flat_map do |child|
            TypeClassResolver.call(child)
          end.compact
        end
      end
    end
  end
end
