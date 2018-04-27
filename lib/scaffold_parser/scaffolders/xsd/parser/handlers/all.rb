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

            def group(new_source)
              STACK.push Module.new("Groups::#{new_source.name.camelize}", elements)
            end

            def complex_type(source)
              if source.has_name?
                STACK.push Klass.new(source.name, elements)
              end

              ComplexType.new elements
            end
          end
        end
      end
    end
  end
end
