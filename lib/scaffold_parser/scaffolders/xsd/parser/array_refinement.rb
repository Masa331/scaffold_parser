module ArrayRefinement
  refine Array do
    def handler
      if empty?
        # zkusit odstranit, tohle by se prece nemelo stat ne??
        ScaffoldParser::Scaffolders::XSD::Parser::Handlers::Blank.new
      elsif one?
        first
      else
        # ScaffoldParser::Scaffolders::XSD::Parser::Handlers::Elements.new(flat_map(&:wip))
        ScaffoldParser::Scaffolders::XSD::Parser::Handlers::Elements.new(self)
      end
    end
  end
end
