module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Sequence
            include OrderElements
            attr_accessor :elements

            def initialize(elements = [])
              @elements = [*elements]
            end

            def complex_type(source)
              if source.has_name?
                STACK.push Klass.new(source, elements)
              end

              ComplexType.new elements
            end

            def group(source)
              STACK.push Module.new(source, elements)
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
