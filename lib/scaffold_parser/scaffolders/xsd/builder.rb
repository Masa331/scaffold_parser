module ScaffoldParser
  module Scaffolders
    class XSD
      class Builder
        attr_reader :node

        def self.call(node, options)
          self.new(node, options).call
        end

        def initialize(node, options)
          @node = node
          @options = options
        end

        def call
          []
        end
      end
    end
  end
end
