module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Elements
            attr_accessor :elements

            def initialize(elements = elements)
              @elements = elements
            end

            def sequence(_)
              self
            end

            def schema(_)
              self
            end

            def choice(_)
              self
            end

            def document(_)
              STACK
            end

            def complex_type(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.methods = elements
                end
                STACK.push template

                Handlers::Blank.new
              else
                self
              end
            end
          end
        end
      end
    end
  end
end
