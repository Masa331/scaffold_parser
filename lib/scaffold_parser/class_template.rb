module ScaffoldParser
  class ClassTemplate
    include TemplateUtils

    attr_accessor :name, :module, :methods, :requires

    def initialize(name = nil)
      @name = name
      @methods = []
      @requires = []

      yield self if block_given?
    end

    def to_s
      f = StringIO.new

      f.puts "class #{name}"
      f.puts "  include BaseParser"
      f.puts

      f.puts methods.map { |method| indent(method.lines).join  }.join("\n\n")

      f.puts "end"

      string = f.string.strip

      wrapped = wrap_in_module(string, 'Parsers')
      with_requires = prepend_requires(wrapped, requires)

      with_requires
    end


    def prepend_requires(string, requires)
      lines = string.lines

      require_strings = requires.map { |r| "require '#{r}'\n" }

      result = require_strings + ["\n"] + lines
      result.join
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
