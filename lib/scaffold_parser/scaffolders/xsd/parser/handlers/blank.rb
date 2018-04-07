module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Blank
            include Base

            def element(source)
              if source.multiple?
                Templates::ListMethod.new(source) do |template|
                  template.item_class = source.has_custom_type? ? source&.type&.classify : 'String'
                end
              elsif source.has_custom_type?
                Templates::SubmodelMethod.new(source)
              else
                Templates::AtMethod.new(source)
              end
            end
          end
        end
      end
    end
  end
end
