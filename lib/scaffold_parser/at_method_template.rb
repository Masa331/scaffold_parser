module ScaffoldParser
  class AtMethodTemplate
    include BaseMethodTemplate
    include TemplateUtils

    def method_body
      "at '#{source.name}'"
    end
  end
end
