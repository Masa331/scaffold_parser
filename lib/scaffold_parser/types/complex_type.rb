module ScaffoldParser
  module Types
    class ComplexType
      def initialize(schema)
        @schema = schema
      end

      def define_accessor(model)
        @schema.children.map do |child|
          type_class = TypeClassResolver.call(child, model)

          node = Node.new
          type_class.new(child).define_accessor(node)
        end
      end
    end
  end
end
