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
        node.list_nodes.each { |n| f.puts "require '#{namespaced(n.to_require)}'" }
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
          f.putsi "    element_xml = at :#{at}"
          f.puts
          f.putsi "    #{klass}.new(element_xml) if element_xml"
          f.putsi "  end"
        end

        node.list_nodes.each do |method|
          f.puts

          klass = method.to_class_name
          list_element_klass = method.list_element_klass
          method_name = method.to_method_name
          at = method.to_location
          list_element_at = method.list_element_at.map { |e| ":#{e}" }.join(', ')

          f.putsi "  def #{method_name}"
          f.putsi "    elements = raw.dig(#{list_element_at}) || []"
          f.putsi "    if elements.is_a? Hash"
          f.putsi "      elements = [elements]"
          f.putsi "    end"
          f.puts
          f.putsi "    elements.map do |raw|"
          f.putsi "      #{list_element_klass}.new(raw)"
          f.putsi "    end"
          f.putsi "  end"
        end

        f.putsi "end"
        f.puts "end" if @options[:namespace]
      end
    end
  end
end
