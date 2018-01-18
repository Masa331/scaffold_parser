module ScaffoldParser
  class Modeler
    def self.call(doc, includes)
      instance = self.new(doc, includes)
      instance.call
    end

    def initialize(doc, includes)
      @doc = doc
      @klass = Klass.new
      @includes = includes
    end

    def call
      @klass.file_name = 'faktura_type.rb'
      @klass.name = 'FakturaType'
      @klass.methods = []

      root_element = @doc.at_xpath('xs:schema/xs:complexType')

      methods = root_element.xpath('xs:sequence/xs:element')
      methods.each do |meth|
        if (type = meth['type'])
          if type.start_with?('xs:')
            name = meth['name'].underscore
            @klass.methods << { name: name, at: meth['name'] }
          else
            type_def = find_type(type)

            if type_def.name == 'simpleType'
              name = meth['name'].underscore
              @klass.methods << { name: name, at: meth['name'] }
            else
            end
          end
        else
          name = meth['name'].underscore
          @klass.methods << { name: name, at: meth['name'] }
        end
      end

      @klass
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
