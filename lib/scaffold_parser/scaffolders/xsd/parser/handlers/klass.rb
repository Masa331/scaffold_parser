module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class Klass
            include Utils

            attr_accessor :name, :namespace, :methods, :inherit_from, :includes

            def initialize(name = nil, elements = [])
              @name = name&.camelize

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
                f.puts "class #{name} < #{inherit_from}"
              else
                f.puts "class #{name}"
              end
              f.puts "  include BaseParser"
              includes.each { |incl| f.puts "  include Groups::#{incl.ref}" }
              if methods.any? || includes.any?
                f.puts if methods.any?
                f.puts methods.map { |method| indent(method.to_s.lines).join  }.join("\n\n")
                f.puts if methods.any?
                f.puts "  def to_h_with_attrs"
                f.puts "    hash = HashWithAttributes.new({}, attributes)"
                f.puts
                methods.each { |method| f.puts "    #{method.to_h_with_attrs_method}" }
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

              wrapped = wrap_in_namespace(string, 'Parsers')
              wrapped = wrap_in_namespace(wrapped, namespace) if namespace

              wrapped
            end

            def to_builder_s
              f = StringIO.new

              if inherit_from
                f.puts "class #{name} < #{inherit_from}"
              else
                f.puts "class #{name}"
              end
              f.puts "  include BaseBuilder"
              f.puts
              f.puts "  def builder"
              f.puts "    root = Ox::Element.new(name)"
              f.puts "    if data.respond_to? :attributes"
              f.puts "      data.attributes.each { |k, v| root[k] = v }"
              f.puts "    end"
              f.puts
              if inherit_from
                f.puts "    super.nodes.each do |n|"
                f.puts "      root << n"
                f.puts "    end"
                f.puts
              end

              f.puts methods.map { |method| indent(indent(method.to_builder.lines)).join  }.join("\n")
              f.puts
              f.puts "    root"
              f.puts "  end"

              f.puts "end"

              string = f.string.strip

              wrapped = wrap_in_namespace(string, 'Builders')
              wrapped = wrap_in_namespace(wrapped, namespace) if namespace

              wrapped
            end
          end
        end
      end
    end
  end
end
