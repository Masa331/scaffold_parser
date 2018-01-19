module ScaffoldParser
  module Types
    class Sequence
      def initialize(schema)
        @schema = schema
      end

      def define_accessor(model)
        @schema.children.map do |element|
          if element.text?
            next
          end

          type_class = TypeClassResolver.call(element, model)

          type_class.new(element).define_accessor(nil)
        end
      end
    end
  end
end
