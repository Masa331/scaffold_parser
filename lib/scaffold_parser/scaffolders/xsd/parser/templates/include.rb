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

            def sequence(_)
              Handlers::Elements.new([self])
            end

            def complex_type(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.includes = [self]
                end
                STACK.push template

                Handlers::Blank.new
              else
                self
              end
            end

            def element(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.includes = [self]
                end
                new_class = STACK.push template

                Templates::SubmodelMethod.new(new_source, new_class.name.camelize)
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
