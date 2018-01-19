module ScaffoldParser
  module Types
    class ElementWithUserType
      def initialize(schema)
        @schema = schema
      end

      def define_accessor(model)
        t = @schema['type']
        t[0] = t[0].upcase

        parent_class = model.name.split('::').first
        element_class = model.const_get(parent_class).const_get(t)

        method_name = @schema['name']
        model.class_eval do
          define_method method_name do
            instance_variable_get("@#{method_name}") || element_class.new
          end

          define_method method_name + "=" do |value|
            instance_variable_set("@#{method_name}", value)
          end
        end
      end
    end
  end
end
