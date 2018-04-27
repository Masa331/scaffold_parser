module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class All
            attr_accessor :elements

            def initialize(elements = [])
              @elements = [*elements]
            end

            def group(source)
              STACK.push Module.new(source, elements)
            end

            def complex_type(source)
              if source.has_name?
                STACK.push Klass.new(source, elements)
              end

              ComplexType.new elements
            end
          end
        end
      end
    end
  end
end
