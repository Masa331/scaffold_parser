module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class Include
            attr_reader :ref

            def initialize(ref)
              @ref = ref
            end
          end
        end
      end
    end
  end
end
