module ScaffoldParser
  module FilePatch
    attr_accessor :indent

    def putsi(str)
      if indent
        puts str.prepend('  ')
      else
        puts str
      end
    end
  end

  File.include FilePatch

  class Builder
    def self.call(doc, options)
      self.new(doc, options).call
    end

    def initialize(doc, options)
      @doc = doc
      @options = options
    end

    def call
      test @doc.end_nodes.any? do |node|
        parent.to_class_name == 'SeznamDalsiSazby'
      end

      if test
        require 'pry'; binding.pry
      end

      @doc.parent_nodes.each do |parent|

        self.class.call(parent, @options)

        if parent.custom_type?
          scaffold_class(parent.type_def)
        else
          scaffold_class(parent)
        end
      end
    end

    private

    def scaffold_class(node)
      unless Dir.exists?('./tmp/')
        Dir.mkdir('./tmp/')
        puts './tmp/ directory created'
      end

      path = "./tmp/#{node.to_file_name}.rb"

      File.open(path, 'wb') do |f|
        f.indent = true if @options[:namespace]

        if @options[:namespace]
          f.puts "require '#{@options[:namespace].underscore}/base_element'"
        else
          f.puts "require 'base_element'"
        end
        node.parent_nodes.each do |n|
          if @options[:namespace]
            f.puts "require '#{@options[:namespace].underscore}/#{n.to_require}'"
          else
            f.puts "require '#{n.to_require}'"
          end
        end
        f.puts

        f.puts "module #{@options[:namespace]}" if @options[:namespace]

        f.putsi "class #{node.to_class_name}"
        f.putsi "  include BaseElement"
        f.puts

        methods = node.end_nodes
        methods.each_with_index do |m, i|
          method_name = m.to_method_name
          at = m.to_location

          f.putsi "  def #{method_name}"
          f.putsi "    at '#{at}'"
          f.putsi "  end"

          f.puts unless i == (methods.size - 1)
        end

        f.puts if node.parent_nodes.any?

        methods = node.parent_nodes
        methods.each_with_index do |m, i|
          klass = m.to_class_name
          method_name = m.to_method_name
          at = m.to_location

          f.putsi "  def #{method_name}"
          f.putsi "    element_xml = at '#{at}'"
          f.puts
          f.putsi "    #{klass}.new(element_xml) if element_xml"
          f.putsi "  end"

          f.puts unless i == (methods.size - 1)
        end

        f.putsi "end"
        f.puts "end" if @options[:namespace]
      end
    end
  end
end
