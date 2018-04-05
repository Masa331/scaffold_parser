module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Blank
            include Base

            def element(source)
              Handlers::Element.new(AtMethodTemplate.new(source))
            end

            def document(_)
              STACK
            end
          end

          def self.const_missing(sym)
            Blank
          end
        end
      end
    end
  end
end
