module ScaffoldParser
  module Types
    class Schema
      attr_accessor :schema

      def initialize(schema)
        @schema = schema
      end

      def call
        schema.children.map do |element|
          type_class = TypeClassResolver.call(element, nil)

          type_class.new(element).define_accessor(nil)
        end
      end

      # def define_attributes(model)
      #   schema.children.each do |element|
      #     type_class = TypeClassResolver.call(element, model)
      #
      #     type_class.new(element).define_accessor(model)
      #   end
      # end
    end
  end
end
