module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          module Base
            def method_missing(sym, *args)
              name = sym.to_s.camelize.to_sym

              if Handlers.constants.include? name
                Handlers.const_get(name).new
              else
                super
              end
            end
          end
        end
      end
    end
  end
end
