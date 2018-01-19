module ScaffoldParser
  class Modeler
    def self.call(doc, includes)
      instance = self.new(doc, includes)
      instance.call
    end

    def initialize(doc, includes)
      @doc = doc
      @klass = Klass.new
      @klass.includes = includes
    end

    def call
      schema = ScaffoldParser::Types::Schema.new(@doc.xpath('xs:schema').first)
      elements = schema.call

      @klass.file_name = 'faktura_type.rb'
      @klass.name = 'FakturaType'
      @klass.methods = []
      @klass

      elements
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
