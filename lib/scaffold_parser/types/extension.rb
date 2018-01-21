module ScaffoldParser
  module Types
    class Extension < BaseType
      def initialize(schema)
        @schema = schema
      end

      def call
        puts 'Beware, extension there!'
        # children = @schema.children.flat_map do |element|
        #   TypeClassResolver.call(element)
        # end.compact
        #
        # node = Node.new
        # node.type = @schema['base']
        # children.each { |c| node.nodes << c }
        # node
      end
    end
  end
end
