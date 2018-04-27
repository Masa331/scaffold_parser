module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ModuleInclude
            attr_reader :ref

            def initialize(ref)
              @ref = ref&.camelize
            end

            def sequence(_)
              Sequence.new self
            end

            def complex_type(new_source)
              if new_source.has_name?
                STACK.push Klass.new(new_source.name.camelize, self)
              else
                self
              end
            end

            def element(new_source)
              if new_source.has_name?
                new_class = STACK.push Klass.new(new_source.name.camelize, self)

                SubmodelMethod.new(new_source, new_class.name.camelize)
              end
            end
          end
        end
      end
    end
  end
end
