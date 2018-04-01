module ScaffoldParser
  class SubmodelMethodTemplate
    include BaseMethodTemplate
    include TemplateUtils

    attr_accessor :submodel_class

    def initialize(source, submodel_class = nil)
      @source = source
      # @submodel_class = submodel_class || source.type.classify
      @submodel_class = submodel_class || source.type.camelize
    end

    def method_body
      "submodel_at(#{submodel_class}, '#{source.name}')"
    end

    def to_h_with_attrs_method
        "hash[:#{method_name}] = #{method_name}.to_h_with_attrs if has? '#{source.name}'"
    end
  end
end
