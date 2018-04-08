module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Blank
            include Base

            def element(source)
              if source.multiple?
                Templates::ListMethod.new(source) do |template|
                  template.item_class = source.has_custom_type? ? source&.type&.classify : 'String'
                end
              elsif source.has_custom_type?
                Templates::SubmodelMethod.new(source)
              else
                Templates::AtMethod.new(source)
              end
            end

            def extension(new_source)
              if new_source.basic_xsd_extension?
                self
              else
                template = Templates::Klass.new do |template|
                  template.methods = []
                  template.inherit_from = new_source.base.camelize
                end

                template
              end
            end

            def include(_)
              self
            end

            def schema(_)
              self
            end
          end
        end
      end
    end
  end
end
