module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ComplexType
            include Base

            def element(source)
              if wip.is_a? Templates::ListMethod
                template = wip.to_proxy_list(source, source.name)

                Element.new template
              elsif source.has_name?
                template = Templates::Klass.new(source.name.camelize) do |template|
                  template.methods = [*wip]
                end
                STACK.push template

                if source.multiple?
                  Element.new Templates::ListMethod.new(source)
                else
                  Element.new Templates::SubmodelMethod.new(source, source.name.camelize)
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
