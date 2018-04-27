require 'scaffold_parser/scaffolders/xsd/parser/module_template'

module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Module
            include Utils

            attr_accessor :name, :namespace, :methods, :includes

            def initialize(name = nil, methods = [])
              @name = name&.camelize
              @methods = methods

              yield self if block_given?
            end

            def schema(_)
              STACK
            end

            def to_s
              ModuleTemplate.new(name.demodulize) do |template|
                template.namespaces = ['Groups', 'Parsers', namespace].compact

                methods.each { |method| template.methods << indent(method.to_s.lines).join  }

                meth = StringIO.new
                meth.puts "  def to_h_with_attrs"
                meth.puts "    hash = HashWithAttributes.new({}, attributes)"
                meth.puts
                methods.each { |method| meth.puts "    #{method.to_h_with_attrs_method}" }
                meth.puts
                meth.puts "    hash"
                meth.puts "  end"

                template.methods << meth.string
              end.to_s
            end

            def to_builder_s
              ModuleTemplate.new(name.demodulize) do |template|
                template.namespaces = ['Groups', 'Builders', namespace].compact

                meth = StringIO.new
                meth.puts "  def builder"
                meth.puts "    root = Ox::Element.new(name)"
                meth.puts "    if data.respond_to? :attributes"
                meth.puts "      data.attributes.each { |k, v| root[k] = v }"
                meth.puts "    end"
                meth.puts
                meth.puts methods.map { |method| indent(indent(method.to_builder.lines)).join  }.join("\n")
                meth.puts
                meth.puts "    root"
                meth.puts "  end"

                template.methods = [meth.string]
              end.to_s
            end
          end
        end
      end
    end
  end
end
