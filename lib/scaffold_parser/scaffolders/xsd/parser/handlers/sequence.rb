module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Sequence
            include Base

            def complex_type(source)
              if source.has_name?
                template = Templates::Klass.new(source.name.camelize) do |template|
                  template.methods = [*wip]
                end
                STACK.push template
                # Blank.new
                Handlers::Blank.new
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
