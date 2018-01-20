module ScaffoldParser
  class Builder
    def self.call(nodes, doc, includes)
      self.new(nodes, doc, includes).call
    end

    def initialize(nodes, doc, includes)
      @nodes = nodes
      @doc = doc
      @includes = includes
    end

    def call
      @nodes.each do |node|
        scaffold_class(node)

        parent_nodes = parent_nodes(node)
        parent_nodes.each do |parent|
          model = find_node_model(parent, @doc, @includes)

          self.class.call([model], @doc, @includes)
        end
      end
    end

    private

    def scaffold_class(node)
      path = "./tmp/#{node.to_file_name}.rb"
      parent_nodes = parent_nodes(node)

      File.open(path, 'wb') do |f|
        parent_nodes.each do |n|
          f.puts "require '#{n.to_require}'"
        end

        f.puts
        f.puts "class #{node.to_class_name}"

        methods = end_nodes(node).map do |method|
          at_method_template(method)
        end
        methods.each_with_index do |m, i|
          f.puts m
          f.puts unless i == (methods.size - 1)
        end

        f.puts if parent_nodes.any?

        methods = parent_nodes.map do |method|
          element_method_template(method)
        end
        methods.each_with_index do |m, i|
          f.puts m
          f.puts unless i == (methods.size - 1)
        end

        f.puts "end"
      end
    end

    def end_nodes(node)
      node.nodes.select do |n|
        model = find_node_model(n, @doc, @includes)
        model.nodes.empty?
      end
    end

    def parent_nodes(node)
      node.nodes.select do |n|
        model = find_node_model(n, @doc, @includes)
        model.nodes.any?
      end
    end

    def at_method_template(method)
      <<-DEF
  def #{method.name.underscore}
    at '#{method.name}'
  end
      DEF
    end

    def element_method_template(method)
      klass = method.type || method.name.classify

      <<-DEF
  def #{method.name.underscore}
    element_xml = at '#{method.name}'

    #{klass}.new(element_xml) if element_xml
  end
      DEF
    end

    def find_node_model(node, doc, includes)
      ble = Nokogiri::XML::Document.new
      ble.root = find_type(node)

      # ble = Nokogiri::XML(find_type(node).to_xml)

      # if node.name = 'Mena'
      #   require 'pry'; binding.pry
      # end

      model = ScaffoldParser::Modeler.call(ble, includes)
    end

    def find_type(node)
      name = node.name

      doc = @includes.find do |doc|
        doc.at_xpath("//*[@name='#{name}']").present?
      end

      if doc.blank?
        fail "Cant find element definition. Might be not enough includes?"
      end

      doc.at_xpath("//*[@name='#{name}']")
    end
  end
end
