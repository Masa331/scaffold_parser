module ScaffoldParser
  module Types
    class Schema
      attr_accessor :schema

      def initialize(schema)
        @schema = schema
      end

      def call
        result = schema.children.map do |element|
          type_class = TypeClassResolver.call(element)

          type_class.new(element).call
        end

        result.compact
      end
    end
  end
end
