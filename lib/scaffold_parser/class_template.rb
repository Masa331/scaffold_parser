module ScaffoldParser
  class ClassTemplate
    include TemplateUtils

    attr_accessor :name, :module, :methods, :inherit_from

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

      wrapped = wrap_in_module(string, 'Parsers')

      wrapped
    end

    def wrap_in_module(klass, module_name)
      lines = klass.lines
      indented = indent(lines)

      indented.unshift "module #{module_name}\n"
      indented << "\nend"

      indented.join
    end
  end
end
