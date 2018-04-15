module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          #TODO this whole class can be thrown away. SimpleType can be called directly on Blank if needed
          class Restriction
            include Base

            def simple_type(source)
              #TODO: Refactor this out. SimpleTypeKlass shouldn't exist
              if source.has_name?
                template = Templates::SimpleTypeKlass.new(source.name.camelize)
                STACK.push template
              end

              Blank.new
            end
          end
        end
      end
    end
  end
end
