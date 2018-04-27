module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ModuleInclude
            attr_reader :ref, :source

            def initialize(source)
              @source = source
              @ref = @source.ref&.camelize
            end

            def full_ref
              if ref.include? ':'
                [ref.split(':')[0], 'groups', ref.split(':')[1]].compact.map(&:camelize).join('::')
              else
                [source.xmlns_prefix, 'groups', ref].compact.map(&:camelize).join('::')
              end
            end

            def sequence(_)
              Sequence.new self
            end

            def complex_type(new_source)
              if new_source.has_name?
                STACK.push Klass.new(new_source, self)
              else
                self
              end
            end

            def element(new_source)
              if new_source.has_name?
                new_class = STACK.push Klass.new(new_source, self)

                SubmodelMethod.new(new_source, new_class.name_with_prefix)
              end
            end
          end
        end
      end
    end
  end
end
