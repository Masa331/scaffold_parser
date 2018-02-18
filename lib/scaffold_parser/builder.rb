module ScaffoldParser
  class Builder
    def self.call(doc, options, already_scaffolded_classes = [])
      self.new(doc, options, already_scaffolded_classes).call
    end

    def initialize(doc, options, already_scaffolded_classes)
      @doc = doc
      @options = options
      @already_scaffolded_classes = already_scaffolded_classes
    end

    def call
      unless Dir.exists?('./tmp/')
        Dir.mkdir('./tmp/')
        puts './tmp/ directory created'
      end

      parent_nodes = @doc.parent_nodes.select do |node|
        !@already_scaffolded_classes.include? node.to_class_name
      end

      parent_nodes.each do |parent|
        @already_scaffolded_classes << parent.to_class_name

        if parent.custom_type?
          type_def = parent.type_def

          scaffold_class(type_def)
          self.class.call(type_def, @options, @already_scaffolded_classes)
        else
          scaffold_class(parent)
          self.class.call(parent, @options, @already_scaffolded_classes)
        end
      end

      list_nodes = @doc.list_nodes.select do |node|
        !@already_scaffolded_classes.include? node.list_element.to_class_name
      end

      list_nodes.each do |list|
        @already_scaffolded_classes << list.list_element.to_class_name

        if list.list_element.custom_type?
          type_def = list.list_element.type_def

          scaffold_class(type_def)
          self.class.call(type_def, @options, @already_scaffolded_classes)
        elsif !list.list_element.xs_type?
          scaffold_class(list.list_element)
          self.class.call(list.list_element, @options, @already_scaffolded_classes)
        end
      end
    end

    private

    def namespaced(path)
      [@options[:namespace]&.underscore, path].compact.join('/')
    end

    def scaffold_class(node)
      path = "./tmp/#{node.to_file_name}.rb"

      File.open(path, 'wb') do |f|
        f.indent = true if @options[:namespace]

        f.puts "require '#{namespaced('base_element')}'"
        node.parent_nodes.each { |n| f.puts "require '#{namespaced(n.to_require)}'" }
        node.list_nodes.reject { |l| l.list_element.xs_type? }.each { |n| f.puts "require '#{namespaced(n.to_require)}'" }
        f.puts

        f.puts "module #{@options[:namespace]}" if @options[:namespace]
        f.putsi "class #{node.to_class_name}"
        f.putsi "  include BaseElement"

        node.end_nodes.each do |method|
          f.puts

          method_name = method.to_method_name
          at = method.to_location

          f.putsi "  def #{method_name}"
          f.putsi "    at :#{at}"
          f.putsi "  end"
        end

        node.parent_nodes.each do |method|
          f.puts

          klass = method.to_class_name
          method_name = method.to_method_name
          at = method.to_location

          f.putsi "  def #{method_name}"
          f.putsi "    submodel_at(#{klass}, :#{at})"
          f.putsi "  end"
        end

        node.list_nodes.reject { |l| l.list_element.xs_type? }.each do |method|
          f.puts

          list_element_klass = method.list_element_klass
          method_name = method.to_method_name
          list_element_at = method.list_element_at.map { |e| ":#{e}" }.join(', ')

          f.putsi "  def #{method_name}"
          f.putsi "    array_of_at(#{list_element_klass}, [#{list_element_at}])"
          f.putsi "  end"
        end

        node.list_nodes.select { |l| l.list_element.xs_type? }.each do |method|
          f.puts

          list_element_klass = method.list_element_klass
          method_name = method.to_method_name
          list_element_at = method.list_element_at.map { |e| ":#{e}" }.join(', ')

          f.putsi "  def #{method_name}"
          f.putsi "    array_of_at(String, [#{list_element_at}])"
          f.putsi "  end"
        end

        f.putsi "end"
        f.puts "end" if @options[:namespace]
      end
    end
  end
end
