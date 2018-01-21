module ScaffoldParser
  class Modeler
    def self.call(doc, includes)
      instance = self.new(doc, includes)
      instance.call
    end

    def initialize(doc, includes)
      @doc = doc
    end

    def call
      schema = @doc.elements.first
      TypeClassResolver.call(schema)
    end
  end
end
