module ScaffoldParser
  module Types
    class Sequence
      def initialize(schema)
        @schema = schema
      end

      def call
        @schema.children.flat_map do |element|
          type_class = TypeClassResolver.call(element)

          type_class.new(element).call
        end.compact
      end
    end
  end
end
