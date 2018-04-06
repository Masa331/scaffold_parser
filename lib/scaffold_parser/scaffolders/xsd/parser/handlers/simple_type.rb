module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class SimpleType
            include Base

            def element(source)
              Element.new(Templates::AtMethod.new(source))
            end
          end
        end
      end
    end
  end
end
