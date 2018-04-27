module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          module Utils
            def indent(lines_or_string)
              if lines_or_string.is_a? Array
                lines_or_string.map { |line| indent_string(line) }
              else
                indent_string(lines_or_string)
              end
            end

            def indent_string(string)
              string == "\n" ? string : string.prepend('  ')
            end

            def single_quote(string)
              string.to_s.gsub('"', '\'')
            end

            def wrap_in_namespace(klass, namespace)
              return klass unless namespace

              lines = klass.lines
              indented = indent(lines)

              indented.unshift "module #{namespace}\n"
              indented << "\nend"

              indented.join
            end
          end
        end
      end
    end
  end
end
