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

    def to_builder
      "root << build_element('#{source.name}', data[:#{source.name.underscore}]) if data.key? :#{source.name.underscore}"
    end
  end
end
