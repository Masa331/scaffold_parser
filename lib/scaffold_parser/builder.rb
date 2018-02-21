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

    def scaffold_class(node)
      Scaffolders::ParserScaffolder.call(node, @options)
    end
  end
end
