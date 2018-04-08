module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class Module
            include Utils

            attr_accessor :name, :namespace, :methods, :includes

            def initialize(name = nil)
              @name = name
              @methods = []

              yield self if block_given?
            end

            def complex_content(_)
              self
            end

            def complex_type(new_source)
              if new_source.has_name?
                fail 'fok'
              else
                self
              end
            end

            def inherit_from
              false
            end

            def element(new_source)
              self.name = new_source.name.camelize
              STACK.push self

              Templates::SubmodelMethod.new(new_source, new_source.name.camelize)
            end

            def ==(other)
              name == other.name &&
                namespace == other.namespace &&
                methods == other.methods
            end

            def to_s
              f = StringIO.new

              f.puts "module #{name}"
              if methods.any?
                f.puts methods.map { |method| indent(method.to_s.lines).join  }.join("\n\n")
                f.puts
                f.puts "  def to_h_with_attrs"
                f.puts "    hash = HashWithAttributes.new({}, attributes)"
                f.puts
                methods.each { |method| f.puts "    #{method.to_h_with_attrs_method}" }
                f.puts
                f.puts "    hash"
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

              f.puts "module #{name}"
              f.puts "  def builder"
              f.puts "    root = Ox::Element.new(name)"
              f.puts "    if data.respond_to? :attributes"
              f.puts "      data.attributes.each { |k, v| root[k] = v }"
              f.puts "    end"
              f.puts

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

            def wrap_in_namespace(klass, namespace)
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
