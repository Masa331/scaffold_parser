require 'scaffold_parser/scaffolders/xsd/parser/module_template'

module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Module
            include Utils

            attr_accessor :name, :namespace, :methods, :includes, :inherit_from

            def initialize(source = nil, methods = [])
              @name = "Groups::#{source.name.camelize}"
              @methods = methods

              @namespace = source.xmlns_prefix&.camelize

              yield self if block_given?
            end

            def schema(_)
              STACK
            end

            def name_with_prefix
              [namespace, name].compact.map(&:camelize).join('::')
            end

            def to_s
              string =
                ModuleTemplate.new(name.demodulize) do |template|
                  template.namespaces = ['Groups'].compact

                  methods.each { |method| template.methods << indent(method.to_s.lines).join  }

                  meth = StringIO.new
                  meth.puts "  def to_h"
                  meth.puts "    hash = {}"
                  meth.puts "    hash[:attributes] = attributes"
                  meth.puts
                  methods.each do |method|
                    method.to_h_method.lines.each do |line|
                      meth.puts "    #{line}"
                    end
                  end
                  meth.puts
                  meth.puts "    hash"
                  meth.puts "  end"

                  template.methods << meth.string
                end.to_s

              wrapped = string
              wrapped = wrap_in_namespace(wrapped, namespace) if namespace

              wrapped
            end

            def to_builder_s
              string =
                ModuleTemplate.new(name.demodulize) do |template|
                  template.namespaces = ['Groups'].compact

                  meth = StringIO.new
                  meth.puts "  def builder"
                  meth.puts "    root = Ox::Element.new(name)"
                  meth.puts "    if data.key? :attributes"
                  meth.puts "      data[:attributes].each { |k, v| root[k] = v }"
                  meth.puts "    end"
                  meth.puts
                  meth.puts methods.map { |method| indent(indent(method.to_builder.lines)).join  }.join("\n")
                  meth.puts
                  meth.puts "    root"
                  meth.puts "  end"

                  template.methods = [meth.string]
                end.to_s

              wrapped = string
              wrapped = wrap_in_namespace(wrapped, namespace) if namespace

              wrapped
            end
          end
        end
      end
    end
  end
end
