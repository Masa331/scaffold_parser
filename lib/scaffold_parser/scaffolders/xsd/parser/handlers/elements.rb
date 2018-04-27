module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Elements
            attr_accessor :elements

            def initialize(elements = [])
              @elements = elements
            end

            def sequence(_)
              flattened = elements.flat_map do |element|
                case element
                when Sequence, Choice, All
                  then element.elements
                else
                  element
                end
              end

              Sequence.new flattened
            end

            def all(_)
              flattened = elements.flat_map do |element|
                case element
                when Sequence, Choice, All
                  then element.elements
                else
                  element
                end
              end

              All.new flattened
            end

            def schema(_)
              STACK
            end

            def choice(_)
              flattened = elements.flat_map do |element|
                case element
                when Sequence, Choice, All
                  then element.elements
                else
                  element
                end
              end

              Choice.new flattened
            end
          end
        end
      end
    end
  end
end
