module ScaffoldParser
  module BaseMethodTemplate
    attr_accessor :source

    def initialize(source)
      @source = source
    end

    def method_name
      source.name.underscore
    end

    def to_s
      f = StringIO.new

      f.puts "def #{method_name}"
      f.puts indent(method_body.lines).join
      f.puts "end"

      f.string.strip
    end
  end
end