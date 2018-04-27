module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Blank
            def elements
              []
            end

            def element(source)
              if source.multiple?
                if elements.any?
                  new_class = STACK.push Klass.new(source, elements)

                  ListMethod.new(source) do |template|
                    template.item_class = new_class.name.classify
                  end
                else
                  ListMethod.new(source) do |template|
                    template.item_class = source.has_custom_type? ? source.type.split(':').map(&:classify).join('::') : 'String'
                  end
                end
              elsif source.has_custom_type?
                SubmodelMethod.new(source)
              elsif source.has_ref?
                # name = source.ref.split(':').map(&:classify).join('::')
                #
                # SubmodelMethod.new(source, name)

                ElementRef.new(source)
              else
                if elements.any?
                  new_class = STACK.push Klass.new(source, elements)
                  SubmodelMethod.new(source, new_class.name_with_prefix)
                else
                  AtMethod.new(source)
                end
              end
            end

            def complex_type(source)
              if source.has_name?
                STACK.push Klass.new(source)
              else
                ComplexType.new
              end
            end

            def extension(source)
              if source.custom_extension?
                Extension.new(elements, source.attributes)
              else # basic xsd extension
                self
              end

            end

            def include(_)
              Include.new
            end

            def import(_)
              Import.new
            end

            def schema(_)
              STACK
            end

            def group(source)
              ModuleInclude.new(source)
            end
          end
        end
      end
    end
  end
end
