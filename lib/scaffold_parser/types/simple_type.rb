module ScaffoldParser
  module Types
    class SimpleType
      def initialize(schema)
        @schema = schema
      end

      def call
        # name = @schema['name']
        #
        # model.class_eval do
        #   attr_accessor name
        # end
      end
    end
  end
end
