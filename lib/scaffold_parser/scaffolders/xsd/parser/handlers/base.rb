module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          module Base
            attr_accessor :wip

            def initialize(wip = nil)
              @wip = wip
            end

            def method_missing(sym, *args)
              Handlers.const_get(sym.to_s.classify).new(wip)
            end
          end
        end
      end
    end
  end
end
