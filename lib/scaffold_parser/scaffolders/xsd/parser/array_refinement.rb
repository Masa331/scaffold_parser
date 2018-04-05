module ArrayRefinement
  refine Array do
    def handler
      if empty?
        ScaffoldParser::Scaffolders::XSD::Parser::Handlers::Blank.new
      elsif one?
        first
      else
        ScaffoldParser::Scaffolders::XSD::Parser::Handlers::Elements.new(flat_map(&:wip))
      end
    end
  end
end
