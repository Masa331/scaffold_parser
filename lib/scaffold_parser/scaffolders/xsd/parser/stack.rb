module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        class Stack
          class SameClassAlreadyInStack < StandardError; end

          include Singleton

          def initialize
            @stack = []
          end

          def push(value)
            same_named_class = @stack.find { |klass| klass.name == value.name }

            if same_named_class
              if same_named_class == value
                same_named_class
              else
                name_base = value.name
                while @stack.find { |klass| klass.name == value.name }
                  counter ||= 1
                  value.name = "#{name_base}#{counter += 1}"
                end
                @stack.push value
                value
              end
            else
              @stack.push value
              value
            end
          end

          # def push_raw(value)
          #   @stack.push value
          # end

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
