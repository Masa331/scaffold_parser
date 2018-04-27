module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Choice
            attr_accessor :elements

            def initialize(elements = [])
              @elements = [*elements]
            end

            def complex_type(source)
              if source.has_name?
                STACK.push Klass.new(source, elements)
              else
                ComplexType.new(elements)
              end
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

            def extension(source)
              Extension.new elements, source.attributes
            end
          end
        end
      end
    end
  end
end
