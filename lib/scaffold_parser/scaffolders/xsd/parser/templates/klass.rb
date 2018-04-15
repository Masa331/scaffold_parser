module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class Klass
            include Utils

            attr_accessor :name, :namespace, :methods, :inherit_from, :includes

            def initialize(name = nil)
              @name = name
              @methods = []
              @includes = []

              yield self if block_given?
            end

            def complex_content(_)
              self
            end

            def complex_type(new_source)
              if new_source.has_name?
                self.name = new_source.name.camelize
                STACK.push self

                Handlers::Blank.new
              else
                self
              end
            end

            def element(new_source)
              self.name = new_source.name.camelize
              STACK.push self

              Templates::SubmodelMethod.new(new_source, new_source.name.camelize)
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
                # if methods.any? { |m| !m.respond_to?(:to_h_with_attrs_method) }
                #   require 'pry'; binding.pry
                # end
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
              # if inherit_from
              #   fail 'fok'
              # end
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
          end
        end
      end
    end
  end
end
