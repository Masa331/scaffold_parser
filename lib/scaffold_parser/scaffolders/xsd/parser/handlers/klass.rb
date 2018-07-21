module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Klass
            include Utils

            attr_accessor :name, :namespace, :methods, :inherit_from, :includes

            def initialize(source = nil, elements = [])
              @name = source&.name&.camelize
              @namespace = source.xmlns_prefix&.camelize

              includes, methods = [*elements].partition do |e|
                e.is_a? ModuleInclude
              end
              inherits, methods = methods.partition do |e|
                e.is_a? ClassInherit
              end

              @methods = methods
              @includes = includes
              @inherit_from = inherits.first.base if inherits.any?

              yield self if block_given?
            end

            def name_with_prefix
              [namespace, name].compact.map(&:camelize).join('::')
            end

            def schema(_)
              STACK
            end

            def ==(other)
              name == other.name &&
                namespace == other.namespace &&
                methods == other.methods &&
                inherit_from == other.inherit_from
            end

            def to_s
              f = StringIO.new

              if inherit_from
                i = inherit_from.split(':').compact.map(&:camelize).join('::')
                f.puts "class #{name} < #{i}"
              else
                f.puts "class #{name}"
              end
              f.puts "  include ParserCore::BaseParser"
              includes.each { |incl| f.puts "  include #{incl.full_ref}" }
              if methods.any? || includes.any?
                f.puts if methods.any?
                f.puts methods.map { |method| indent(method.to_s.lines).join  }.join("\n\n")
                f.puts if methods.any?
                f.puts "  def to_h"
                f.puts "    hash = {}"
                f.puts "    hash[:attributes] = attributes"
                f.puts
                methods.each do |method|
                  method.to_h_method.lines.each do |line|
                    f.puts "    #{line}"
                  end
                end
                f.puts if methods.any?
                if includes.any?
                  f.puts "    mega.inject(hash) { |memo, r| memo.merge r }"
                else
                  f.puts "    hash"
                end
                if inherit_from
                  f.puts "    super.merge(hash)"
                end
                f.puts "  end"
              end

              f.puts "end"

              string = f.string.strip

              wrapped = string
              wrapped = wrap_in_namespace(wrapped, namespace) if namespace

              wrapped
            end

            def to_builder_s
              f = StringIO.new

              if inherit_from
                i = inherit_from.split(':').compact.map(&:camelize).join('::')
                f.puts "class #{name} < #{i}"
              else
                f.puts "class #{name}"
              end
              f.puts "  include ParserCore::BaseBuilder"
              includes.each { |incl| f.puts "  include #{incl.full_ref}" }
              f.puts
              f.puts "  def builder"
              f.puts "    root = Ox::Element.new(name)"
              f.puts "    if data.key? :attributes"
              f.puts "      data[:attributes].each { |k, v| root[k] = v }"
              f.puts "    end"
              f.puts
              if inherit_from
                f.puts "    super.nodes.each do |n|"
                f.puts "      root << n"
                f.puts "    end"
                f.puts
              end

              if methods.any?
                f.puts methods.map { |method| indent(indent(method.to_builder.lines)).join  }.join("\n")
                f.puts
              end
              if includes.any?
                f.puts "    mega.each do |r|"
                f.puts "      r.nodes.each { |n| root << n }"
                f.puts "    end"
                f.puts
              end
              f.puts "    root"
              f.puts "  end"

              f.puts "end"

              string = f.string.strip

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
