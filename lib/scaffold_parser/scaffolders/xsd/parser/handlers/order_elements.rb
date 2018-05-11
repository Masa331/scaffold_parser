module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          module OrderElements
            def sequence(_)
              flattened = elements.flat_map do |element|
                case element
                when Sequence, Choice, All
                  element.elements
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
                  element.elements
                else
                  element
                end
              end

              All.new flattened
            end

            def choice(_)
              flattened = elements.flat_map do |element|
                case element
                when Sequence, Choice, All
                  element.elements
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
