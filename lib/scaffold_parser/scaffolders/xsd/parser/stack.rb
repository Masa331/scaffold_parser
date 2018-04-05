module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        class Stack
          include Singleton

          def initialize
            @stack = []
          end

          def push(value)
            @stack.push value
          end

          def clear
            @stack.clear
          end

          def to_a
            @stack
          end
        end
      end
    end
  end
end
