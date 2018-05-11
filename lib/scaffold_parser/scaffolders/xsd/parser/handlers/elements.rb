module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Elements
            include OrderElements

            attr_accessor :elements

            def initialize(elements = [])
              @elements = elements
            end

            def schema(_)
              STACK
            end
          end
        end
      end
    end
  end
end
