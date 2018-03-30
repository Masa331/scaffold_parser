module ScaffoldParser
  class MethodTemplate
    include TemplateUtils

    attr_accessor :name, :body

    def initialize(name = nil)
      @name = name
      yield self if block_given?
    end

    def to_s
      f = StringIO.new

      f.puts "def #{name}"
      f.puts indent(body.lines).join
      f.puts "end"

      f.string.strip
    end
  end
end
