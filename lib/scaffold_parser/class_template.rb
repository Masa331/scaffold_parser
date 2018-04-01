module ScaffoldParser
  class ClassTemplate
    include TemplateUtils

    attr_accessor :name, :namespace, :methods, :inherit_from

    def initialize(name = nil)
      @name = name
      @methods = []

      yield self if block_given?
    end

    def to_s
      f = StringIO.new

      if inherit_from
        f.puts "class #{name} < #{inherit_from}"
      else
        f.puts "class #{name}"
      end
      f.puts "  include BaseParser"
      f.puts

      f.puts methods.map { |method| indent(method.to_s.lines).join  }.join("\n\n")
      f.puts
      f.puts "  def to_h_with_attrs"
      f.puts "    hash = HashWithAttributes.new({}, attributes)"
      f.puts
      methods.each { |method| f.puts "    #{method.to_h_with_attrs_method}" }
      f.puts
      f.puts "    hash"
      if inherit_from
        f.puts "    super.merge(hash)"
      end
      f.puts "  end"

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

    def wrap_in_namespace(klass, namespace)
      lines = klass.lines
      indented = indent(lines)

      indented.unshift "module #{namespace}\n"
      indented << "\nend"

      indented.join
    end
  end
end
