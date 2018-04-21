module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Elements
            attr_accessor :elements

            #TODO wtf
            def initialize(elements = elements)
              @elements = elements
            end

            def sequence(_)
              self
            end

            def schema(_)
              STACK
            end

            def choice(_)
              self
            end

            def complex_type(new_source)
              if new_source.has_name?
                includes, methods = elements.partition do |e|
                  e.is_a? Templates::Include
                end

                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.methods = methods
                  template.includes = includes
                end
                STACK.push template

                Handlers::Blank.new
              else
                self
              end
            end

            def element(new_source)
              if new_source.has_name?
                includes, methods = elements.partition do |e|
                  e.is_a? Templates::Include
                end

                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.methods = methods
                  template.includes = includes
                end
                new_class = STACK.push template

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
                  Templates::SubmodelMethod.new(new_source, new_class.name.camelize)
                end
              else
                self
              end
            end

            def extension(new_source)
              includes, methods = elements.partition do |e|
                e.is_a? Templates::Include
              end

              template = Templates::Klass.new do |template|
                template.methods = methods
                template.includes = includes
                template.inherit_from = new_source.base.camelize
              end

              template
            end

            def group(new_source)
              # require 'pry'; binding.pry
              # template = Templates::Module.new(new_source.name.camelize) do |template|
              template = Templates::Module.new("Groups::#{new_source.name.camelize}") do |template|
                template.methods = elements
              end

              STACK.push template

              Handlers::Blank.new
            end
          end
        end
      end
    end
  end
end
