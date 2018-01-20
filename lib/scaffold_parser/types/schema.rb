module ScaffoldParser
  module Types
    class Schema < BaseType
      attr_accessor :schema

      def initialize(schema)
        @schema = schema
      end

      def call
        schema.children.map do |element|
          TypeClassResolver.call(element)
        end.compact
      end
    end
  end
end
