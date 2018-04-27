require 'scaffold_parser/scaffolders/xsd/parser/handlers/utils'

module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        class ModuleTemplate
          include Handlers::Utils

          attr_accessor :name, :methods, :namespaces

          def initialize(name = nil)
            @name = name
            @methods = []
            @namespaces = []

            yield self if block_given?
          end

          def to_s
            f = StringIO.new

            f.puts "module #{name}"
            f.puts methods.join("\n\n")

            f.puts "end"
            string = f.string.strip

            namespaces.inject(string) { |string, n| wrap_in_namespace(string, n) }
          end
        end
      end
    end
  end
end
