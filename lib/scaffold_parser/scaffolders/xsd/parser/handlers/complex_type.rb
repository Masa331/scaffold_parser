module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ComplexType
            include Base

            def element(source)
              if source.has_name?
                Templates::ListMethod.new(source) do |template|
                  template.item_class = 'String'
                end
              else
                fail 'fok'
              end
            end
          end
        end
      end
    end
  end
end
