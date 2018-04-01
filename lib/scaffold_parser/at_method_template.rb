module ScaffoldParser
  class AtMethodTemplate
    include BaseMethodTemplate
    include TemplateUtils

    def method_body
      "at '#{source.name}'"
    end

    def to_h_with_attrs_method
      "hash[:#{method_name}] = #{method_name} if has? '#{source.name}'"
    end
  end
end
