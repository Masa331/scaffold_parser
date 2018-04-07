module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Blank
            include Base

            def element(source)
              if source.multiple?
                Element.new(Templates::ListMethod.new(source))
              elsif source.has_custom_type?
                Element.new(Templates::SubmodelMethod.new(source))
              else
                Element.new(Templates::AtMethod.new(source))
              end
            end

            def schema(_)
              Schema.new
            end
          end
        end
      end
    end
  end
end
