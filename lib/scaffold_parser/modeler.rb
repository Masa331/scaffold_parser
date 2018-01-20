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
      # schema = @doc.xpath('xs:schema').first
      # ScaffoldParser::Types::Schema.call(schema)

      schema = @doc.elements.first
      TypeClassResolver.call(schema)
    end

    private

    def find_type(name)
      doc = @includes.find do |doc|
        doc.at_xpath("//*[@name='#{name}']").present?
      end

      if doc.blank?
        fail "Cant find element definition. Might be not enough includes?"
      end

      doc.at_xpath("//*[@name='#{name}']")
    end
  end
end
