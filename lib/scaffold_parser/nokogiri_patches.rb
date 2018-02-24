module ScaffoldParser
  module NokogiriPatches
    module Element
      class BlankExtension
        def submodel_nodes
          []
        end

        def value_nodes
          []
        end

        def array_nodes
          []
        end
      end

      def submodel_nodes
        attribute_elements.select(&:parent_type?) + extension.submodel_nodes
      end

      def value_nodes
        attribute_elements.select(&:end_type?) + extension.value_nodes
      end

      def array_nodes
        attribute_elements.select(&:list_type?) + extension.array_nodes
      end

      def end_type?
        xs_type? || (no_type? && complex_types.empty? && !complex_type? && !list_type?)
      end

      def parent_type?
        (complex_type? || complex_types.any?) && !list_type?
      end

      def list_type?
        if definition.list_element
          max_occure = definition.list_element['maxOccurs']

          max_occure == 'unbounded' || max_occure.to_i > 1
        end
      end

      def list_element_klass
        list_element.definition.to_name.camelize
      end

      def list_element_at
        [at_xpath('xs:complexType').to_name, list_element.to_name]
      end

      def to_class_name
        definition.to_name.camelize
      end

      def definition
        if self['type'].present? && !self['type'].start_with?('xs:')
          find_type(self['type'])
        else
          self
        end
      end

      def list_element
        xpath('xs:complexType/xs:sequence/xs:element').first
      end

      def extension
        elem = at_xpath('xs:complexType/xs:complexContent/xs:extension')

        elem ? find_type(elem['base']) : BlankExtension.new
      end

      def xs_type?
        definition['type'].present? && definition['type'].start_with?('xs:')
      end

      def complex_type?
        definition.name == 'complexType'
      end

      def complex_types
        definition.xpath('xs:complexType')
      end

      def no_type?
        definition['type'].blank?
      end

      def to_name
        self['name'] || at_xpath('..')['name']
      end

      private

      def attribute_elements
        xpath('xs:sequence/xs:element|xs:sequence/xs:sequence/xs:element|xs:sequence/xs:choice/xs:sequence/xs:element|xs:sequence/xs:choice/xs:element|xs:complexType/xs:sequence/xs:element')
      end

      def find_type(name)
        if element = document.at_xpath("//*[@name='#{name}']")
          return element
        else
          collect_includes.find do |doc|
            doc.at_xpath("//*[@name='#{name}']").present?
          end.at_xpath("//*[@name='#{name}']")
        end
      end

      def collect_includes(doc = self, collection = [], names = [])
        new_names = doc.xpath('//xs:include').map { |incl| incl['schemaLocation'] }

        (new_names - names).each do |name|
          new_doc = Nokogiri::XML(File.open(name))

          collection << new_doc
          names << name

          collect_includes(new_doc, collection, names)
        end

        collection
      end
    end

    module Document
      def submodel_nodes
        xpath('xs:schema/xs:complexType|xs:schema/xs:element')
      end

      def array_nodes
        []
      end
    end
  end
end
