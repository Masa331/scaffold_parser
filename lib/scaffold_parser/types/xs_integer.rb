module ScaffoldParser
  module Types
    class XsInteger
      def initialize(schema)
        @schema = schema
      end

      def define_accessor(model)
        name = @schema['name']

        model.class_eval do
          attr_accessor name
        end
      end
    end
  end
end
