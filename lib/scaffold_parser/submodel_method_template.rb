module ScaffoldParser
  class SubmodelMethodTemplate
    include BaseMethodTemplate
    include TemplateUtils

    attr_accessor :submodel_class

    def initialize(source, submodel_class)
      @source = source
      @submodel_class = submodel_class
    end

    def method_body
      "submodel_at(#{submodel_class}, '#{source.name}')"
    end
  end
end
