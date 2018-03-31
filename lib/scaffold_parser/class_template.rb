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

      f.puts "class #{name}"
      f.puts "  include BaseParser"
      f.puts

      f.puts methods.map { |method| indent(method.to_s.lines).join  }.join("\n\n")
      f.puts
      f.puts "  def to_h_with_attrs"
      f.puts "    hash = HashWithAttributes.new({}, attributes)"
      f.puts
      methods.each do |method|
        if method.is_a? AtMethodTemplate
          f.puts "    hash[:#{method.method_name}] = #{method.method_name} if has? '#{method.source.name}'"
        elsif method.is_a? SubmodelMethodTemplate
          f.puts "    hash[:#{method.method_name}] = #{method.method_name}.to_h_with_attrs if has? '#{method.source.name}'"
        elsif method.is_a? ListMethodTemplate
          f.puts "    hash[:#{method.method_name}] = #{method.method_name}.map(&:to_h_with_attrs) if has? '#{method.source.name}'"
        elsif method.is_a? StringListMethodTemplate
          f.puts "    hash[:#{method.method_name}] = #{method.method_name} if has? '#{method.source.name}'"
        end
      end
      f.puts
      f.puts "    hash"
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
