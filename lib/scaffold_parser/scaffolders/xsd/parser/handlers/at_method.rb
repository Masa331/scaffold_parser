module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class AtMethod
            include BaseMethod
            include Utils

            def to_s
              f = StringIO.new

              f.puts "def #{method_name}"
              f.puts indent(method_body.lines).join
              f.puts "end"

              f.puts

              f.puts "def #{method_name}_attributes"
              f.puts "  attributes_at '#{at}'"
              f.puts "end"

              f.string.strip
            end

            def method_body
              "at '#{at}'"
            end

            def at
              [source.xmlns_prefix, "#{source.name}"].compact.join(':')
            end

            def to_h_method
              "hash[:#{method_name}] = #{method_name} if has? '#{at}'\n"\
                "hash[:#{method_name}_attributes] = #{method_name}_attributes if has? '#{at}'"
            end

            def to_builder
              "root << build_element('#{at}', data[:#{method_name}], data[:#{method_name}_attributes]) if data.key? :#{method_name}"
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
