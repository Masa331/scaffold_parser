module ScaffoldParser
  class Builder
    def self.call(node, doc, includes)
      self.new(node, doc, includes).call
    end

    def initialize(node, doc, includes)
      @node = node
      @doc = doc
      @includes = includes
    end

    def call
      @parent_nodes = parent_nodes(@node)
      @end_nodes = end_nodes(@node)

      @parent_nodes.each do |parent|
        model = find_node_model(parent, @doc, @includes)

        self.class.call(model, @doc, @includes)
      end

      scaffold_class(@node)
    end

    private

    def scaffold_class(node)
      path = "./tmp/#{node.to_file_name}.rb"

      File.open(path, 'wb') do |f|
        @parent_nodes.each do |n|
          f.puts "require '#{n.to_require}'"
        end

        f.puts
        f.puts "class #{node.to_class_name}"

        methods = @end_nodes.map do |method|
          at_method_template(method)
        end
        methods.each_with_index do |m, i|
          f.puts m
          f.puts unless i == (methods.size - 1)
        end

        f.puts if @parent_nodes.any?

        methods = @parent_nodes.map do |method|
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
        if n.type
          model = find_node_model(n, @doc, @includes)
          model.nil? || model.nodes.empty?
        else
          n.nodes.empty?
        end
      end
    end

    def parent_nodes(node)
      node.nodes.select do |n|
        if n.type
          model = find_node_model(n, @doc, @includes)
          model && model.nodes.any?
        else
          n.nodes.any?
        end
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
      klass = (method.type || method.name).classify

      <<-DEF
  def #{method.name.underscore}
    element_xml = at '#{method.name}'

    #{klass}.new(element_xml) if element_xml
  end
      DEF
    end

    def find_node_model(node, doc, includes)
      if node.type
        ble = Nokogiri::XML::Document.new
        ble.root = find_type(node)

        model = ScaffoldParser::Modeler.call(ble, includes)
        model
      else
        node
      end
    end

    def find_type(node)
      name = node.name
      name = node.type

      doc = @includes.find do |doc|
        doc.at_xpath("//*[@name='#{name}']").present?
      end

      # if node.type == 'xs:string'
      #   require 'pry'; binding.pry
      # end
      if doc.blank?
        fail "Cant find element definition for #{node.name}(#{node.type}). Might be not enough includes?"
      end

      doc.at_xpath("//*[@name='#{name}']")
    end
  end
end
