module ScaffoldParser
  class ListMethodTemplate
    include BaseMethodTemplate
    include TemplateUtils

    attr_accessor :at, :item_class

    def initialize(source)
      @source = source
      @at = [source.name]
      @item_class = source&.type&.classify
    end

    def method_body
      "array_of_at(#{item_class}, #{single_quote(at)})"
    end
  end
end
