module ScaffoldParser
  class ProxyListMethodTemplate
    include BaseMethodTemplate
    include TemplateUtils

    attr_accessor :at, :item_class

    def initialize(source)
      @source = source
      @at = [source.name, source.children.last.name]
      @item_class = source.children.last&.type&.classify || 'String'
    end

    def method_body
      "array_of_at(#{item_class}, #{single_quote(at)})"
    end

    def to_h_with_attrs_method
      if item_class == 'String'
        "hash[:#{method_name}] = #{method_name} if has? '#{source.name}'"
      else
        "hash[:#{method_name}] = #{method_name}.map(&:to_h_with_attrs) if has? '#{source.name}'"
      end
    end
  end
end
