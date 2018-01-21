module ScaffoldParser
  module Types
    class Group < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        puts 'Beware, group there!'

        node = Node.new
        node.name = 'group'
        node.element_type = 'group'
        node
      end
    end
  end
end
