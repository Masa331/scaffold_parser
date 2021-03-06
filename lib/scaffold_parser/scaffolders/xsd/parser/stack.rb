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
            similar_classes = @stack.select { |klass| klass.name.start_with? value.name }

            if similar_classes.any?
              same_structure_class = similar_classes.find do |kl|
                kl.namespace == value.namespace &&
                  kl.methods == value.methods &&
                  kl.inherit_from == value.inherit_from
              end

              if same_structure_class
                same_structure_class
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
