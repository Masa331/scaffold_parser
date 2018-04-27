module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
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
