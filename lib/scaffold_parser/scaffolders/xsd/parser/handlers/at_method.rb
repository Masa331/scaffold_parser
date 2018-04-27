module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class AtMethod
            include BaseMethod
            include Utils

            def method_body
              "at '#{at}'"
            end

            def at
              [source.xmlns_prefix, "#{source.name}"].compact.join(':')
            end

            def to_h_with_attrs_method
              "hash[:#{method_name}] = #{method_name} if has? '#{at}'"
            end

            def to_builder
              "root << build_element('#{at}', data[:#{method_name}]) if data.key? :#{method_name}"
            end

            def sequence(_)
              Sequence.new self
            end

            def choice(_)
              Choice.new self
            end

            def all(_)
              All.new self
            end
          end
        end
      end
    end
  end
end
