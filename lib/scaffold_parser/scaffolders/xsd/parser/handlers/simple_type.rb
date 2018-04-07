module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class SimpleType
            include Base

            def element(source)
              Templates::AtMethod.new(source)
            end
          end
        end
      end
    end
  end
end
