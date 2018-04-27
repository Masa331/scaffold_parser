module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          module BaseMethod
            attr_accessor :source

            def initialize(source)
              @source = source
            end

            def method_name
              # [source.xmlns_prefix, source.name.underscore].compact.join('_')
              # [source.xmlns_prefix, source.name.underscore].compact.join('_')
              # if source.name.blank?
              #   require 'pry'; binding.pry
              # end
              if source.name
                source.name.underscore
              elsif source.ref
                prefix, name = source.ref.split(':')
                name.underscore
              end
            end

            def to_s
              f = StringIO.new

              f.puts "def #{method_name}"
              f.puts indent(method_body.lines).join
              f.puts "end"

              f.string.strip
            end

            def ==(other)
              method_name == other.method_name &&
                method_body == other.method_body
            end
          end
        end
      end
    end
  end
end
