module ScaffoldParser
  class Builder
    def self.call(doc)
      self.new(doc).call
    end

    def initialize(doc)
      @doc = doc
    end

    def call
      @doc.parent_nodes.each do |parent|
        self.class.call(parent)

        scaffold_class(parent)
      end
    end

    private

    def scaffold_class(node)
      path = "./tmp/#{node.to_file_name}.rb"

      File.open(path, 'wb') do |f|
        node.parent_nodes.each do |n|
          f.puts "require '#{n.to_require}'"
        end

        f.puts
        f.puts "class #{node.to_class_name}"

        methods = node.end_nodes.map do |method|
          at_method_template(method)
        end
        methods.each_with_index do |m, i|
          f.puts m
          f.puts unless i == (methods.size - 1)
        end

        f.puts if node.parent_nodes.any?

        methods = node.parent_nodes.map do |method|
          element_method_template(method)
        end
        methods.each_with_index do |m, i|
          f.puts m
          f.puts unless i == (methods.size - 1)
        end

        f.puts "end"
      end
    end


    def at_method_template(node)
      method_name = node.to_method_name
      at = node.to_location

      <<-DEF
  def #{method_name}
    at '#{at}'
  end
      DEF
    end

    def element_method_template(node)
      klass = node.to_class_name
      method_name = node.to_method_name
      at = node.to_location

      <<-DEF
  def #{method_name}
    element_xml = at '#{at}'

    #{klass}.new(element_xml) if element_xml
  end
      DEF
    end
  end
end
