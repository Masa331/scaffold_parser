module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ComplexType
            include Base

            def element(source)
              if source.has_name?
                template = ClassTemplate.new(source.name.camelize) do |template|
                  template.methods = [*wip]
                end
                STACK.push template
                Handlers::Element.new SubmodelMethodTemplate.new(source, source.name.camelize)
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
