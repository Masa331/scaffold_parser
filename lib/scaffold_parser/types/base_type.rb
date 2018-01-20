module ScaffoldParser
  module Types
    class BaseType
      def self.call(schema)
        self.new(schema).call
      end

      def initialize(schema)
      end

      def call
      end
    end
  end
end
