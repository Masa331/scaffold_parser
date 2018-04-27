module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ClassInherit
            attr_reader :base

            def initialize(base)
              @base = base&.camelize
            end
          end
        end
      end
    end
  end
end
