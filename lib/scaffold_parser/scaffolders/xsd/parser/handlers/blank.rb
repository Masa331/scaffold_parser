module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Blank
            include Base

            def element(source)
              Element.new(Templates::AtMethod.new(source))
            end

            def document(_)
              STACK
            end
          end
        end
      end
    end
  end
end
