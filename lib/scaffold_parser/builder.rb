module ScaffoldParser
  class Builder
    def self.call(doc, options, already_scaffolded_subelements = [])
      self.new(doc, options, already_scaffolded_subelements).call
    end

    def initialize(doc, options, already_scaffolded_subelements)
      @doc = doc
      @options = options
      @already_scaffolded_subelements = already_scaffolded_subelements
    end

    def call
      unless Dir.exists?('./tmp/')
        Dir.mkdir('./tmp/')
        puts './tmp/ directory created'
      end

      unscaffolded_subelements.each do |subelement|
        @already_scaffolded_subelements << subelement.to_class_name

        type_def =
          if subelement.custom_type?
            subelement.type_def
          else
            subelement
          end

        Scaffolders::ParserScaffolder.call(type_def, @options)
        self.class.call(type_def, @options, @already_scaffolded_subelements)
      end
    end

    private

    def unscaffolded_subelements
      all = @doc.parent_nodes.to_a + @doc.list_nodes.map(&:list_element)

      all
        .reject(&:xs_type?)
        .reject { |node| @already_scaffolded_subelements.include?(node.to_class_name) }
    end
  end
end
