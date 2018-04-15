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

            def complex_type(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize)

                STACK.push template

                Handlers::Blank.new
              else
                # require 'pry'; binding.pry
                # fail 'fok'

                Handlers::Blank.new
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

            def group(source)
              if source.has_ref?
                Templates::Include.new(source.ref.camelize)
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
