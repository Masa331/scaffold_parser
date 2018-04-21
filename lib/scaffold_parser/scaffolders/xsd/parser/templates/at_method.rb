module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class AtMethod
            include BaseMethod
            include Utils

            def method_body
              "at '#{source.name}'"
            end

            def to_h_with_attrs_method
              "hash[:#{method_name}] = #{method_name} if has? '#{source.name}'"
            end

            def to_builder
              "root << build_element('#{source.name}', data[:#{source.name.underscore}]) if data.key? :#{source.name.underscore}"
            end

            def sequence(_)
              self
            end

            def choice(_)
              self
            end

            def all(_)
              self
            end

            # def ==(other)
            #   method_name == other.method_name &&
            #     method_body == other.method_body
            # end

            def complex_type(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.methods = [self]
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
                  template.methods = [self]
                end
                STACK.push template

                if new_source.multiple?
                  Templates::ListMethod.new(new_source) do |template|
                    template.item_class =
                      if new_source.has_custom_type?
                        new_source&.type&.classify
                      else
                        new_source&.name&.classify
                      end
                  end
                else
                  Templates::SubmodelMethod.new(new_source, new_source.name.camelize)
                end
              else
                fail 'fok'
              end
            end

            def extension(new_source)
              template = Templates::Klass.new do |template|
                template.methods = [self]
                template.inherit_from = new_source.base.camelize
              end

              template
            end

            def group(new_source)
              template = Templates::Module.new("Groups::#{new_source.name.camelize}") do |template|
                template.methods = [self]
              end

              STACK.push template
            end
          end
        end
      end
    end
  end
end
