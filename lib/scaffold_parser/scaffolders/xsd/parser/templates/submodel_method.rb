module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class SubmodelMethod
            include BaseMethod
            include Utils

            attr_accessor :submodel_class

            def initialize(source, submodel_class = nil)
              @source = source
              @submodel_class = submodel_class || source.type.camelize
            end

            def method_body
              "submodel_at(#{submodel_class}, '#{source.name}')"
            end

            def to_h_with_attrs_method
              "hash[:#{method_name}] = #{method_name}.to_h_with_attrs if has? '#{source.name}'"
            end

            def to_builder
              f = StringIO.new

              f.puts "if data.key? :#{method_name}"
              f.puts "  root << #{submodel_class}.new('#{source.name}', data[:#{source.name.underscore}]).builder"
              f.puts 'end'

              f.string.strip
            end

            def sequence(_)
              self
            end

            def schema(_)
              STACK
              # self
            end

            # def document(_)
            #   STACK
            # end

            def to_at_method
              Templates::AtMethod.new(source)
            end

            def element(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.methods = [self]
                end
                STACK.push template

                Templates::SubmodelMethod.new(new_source, new_source.name.camelize)
                # Handlers::Blank.new
              else
                fail 'fok'
              end
            end

            def complex_type(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.methods = [self]
                end
                STACK.push template

                Handlers::Blank.new
              else
              #   fail 'fok'
                self
              end
            end

            def extension(new_source)
              template = Templates::Klass.new do |template|
                template.methods = [self]
                template.inherit_from = new_source.base.camelize
              end

              template
            end
          end
        end
      end
    end
  end
end
