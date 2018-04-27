module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ComplexType
            attr_accessor :elements

            def initialize(elements = [])
              @elements = elements
            end

            def schema(_)
              STACK
            end

            def element(source)
              if source.multiple?
                if elements.any?
                  new_class = STACK.push Klass.new(source.name, elements)

                  ListMethod.new(source) do |template|
                    template.item_class = new_class.name.camelize
                  end
                else
                  ListMethod.new(source) do |template|
                    template.item_class = source.has_custom_type? ? source&.type&.classify : 'String'
                  end
                end
              elsif source.has_custom_type?
                SubmodelMethod.new(source)
              else
                if elements.any?
                  new_class = STACK.push Klass.new(source.name, elements)
                  SubmodelMethod.new(source, new_class.name.camelize)
                else
                  AtMethod.new(source)
                end
              end
            end
          end
        end
      end
    end
  end
end
