module ScaffoldParser
  module Types
    class Group
      def initialize(schema)
        @schema = schema
      end

      def define_accessor(model)
        if !@schema['ref'].nil?
          t = @schema['ref']
          t[0] = t[0].upcase
          parent_class = model.name.split('::').first
          nodule = model.const_get(parent_class).const_get(t)

          model.include nodule
        end
      end
    end
  end
end
