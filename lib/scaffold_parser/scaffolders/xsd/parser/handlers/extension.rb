module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Extension
            attr_accessor :elements, :attributes

            def initialize(elements = [], attributes)
              @elements = [*elements]
              @attributes = attributes
            end

            def complex_type(source)
              if source.has_name?
                template = Klass.new(source, elements) do |template|
                  template.inherit_from = attributes['base'].camelize
                end

                STACK.push template
              else
                ComplexType.new elements + [ClassInherit.new(attributes['base'])]
              end
            end
          end
        end
      end
    end
  end
end
