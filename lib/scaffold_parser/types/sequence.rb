module ScaffoldParser
  module Types
    class Sequence < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        @schema.children.flat_map do |element|
          TypeClassResolver.call(element)
        end.compact
      end
    end
  end
end
