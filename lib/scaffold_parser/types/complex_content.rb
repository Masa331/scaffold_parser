module ScaffoldParser
  module Types
    class ComplexContent < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        @schema.children.flat_map do |child|
          TypeClassResolver.call(child)
        end.compact
      end
    end
  end
end
