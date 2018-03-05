module ScaffoldParser
  module NokogiriPatches
    class DefinitionNotFound < StandardError; end

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
        (xs_type? && !list_type?) || (no_type? && complex_types.empty? && !complex_type? && !list_type?)
      end

      def parent_type?
        (complex_type? || complex_types.any?) && !list_type?
      end

      def max_occurs
        case self['maxOccurs']
        when 'unbounded'
          Float::INFINITY
        when String
          self['maxOccurs'].to_i
        else
          1
        end
      end

      def list_type?
        simple_list? || named_list?
      end

      def simple_list?
        max_occurs > 1
      end

      def named_list?
        # definition.list_element.present? && definition.list_element.max_occurs > 1
        !simple_list? && definition.list_element.present? && definition.list_element.max_occurs > 1
      end

      def list_element
        if simple_list?
          self
        else
          xpath('xs:complexType/xs:sequence/xs:element').first
        end
      end

      def list_element_klass
        if simple_list?
          definition.to_name.camelize
        elsif named_list?
          list_element.definition.to_name.camelize
        end
      end

      def list_element_at
        if simple_list?
          [to_name]
        elsif named_list?
          [at_xpath('xs:complexType').to_name, list_element.to_name]
        end
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

      def extension
        complex_ext = at_xpath('xs:complexType/xs:complexContent/xs:extension')
        # Can be also simple extension but i don't have to do anything with these:
        # simple_ext = at_xpath('xs:complexType/xs:simpleContent/xs:extension')

        complex_ext ? find_type(complex_ext['base']) : BlankExtension.new
      end

      def extended_simple_type?
        simple_ext = at_xpath('xs:complexType/xs:simpleContent/xs:extension')

        simple_ext.present?
      end

      def xs_type?
        (definition['type'].present? && definition['type'].start_with?('xs:')) || extended_simple_type?
      end

      def complex_type?
        definition.name == 'complexType'
      end

      def complex_types
        definition.xpath('xs:complexType[not(xs:simpleContent)]')
      end

      def no_type?
        definition['type'].blank?
      end

      def to_name
        self['name'] || at_xpath('..')['name']
      end

      private

      def attribute_elements
        xpath('xs:sequence/xs:element',
              'xs:sequence/xs:sequence/xs:element',
              'xs:sequence/xs:choice/xs:sequence/xs:element',
              'xs:sequence/xs:choice/xs:element',
              'xs:complexType/xs:sequence/xs:element',
              'xs:complexType/xs:choice/xs:element',
              'xs:complexType/xs:complexContent/xs:extension/xs:sequence/xs:element',
              'xs:complexContent/xs:extension/xs:sequence/xs:element'
             )
      end

      def find_type(name)
        if element = document.at_xpath("//*[@name='#{name}']")
          return element
        else
          definition_schema = collect_includes.find do |doc|
            doc.at_xpath("//*[@name='#{name}']").present?
          end

          if definition_schema.blank?
            fail DefinitionNotFound.new("Couldn't find type definiton for '#{name}' in any included schema.")
          end

          definition_schema.at_xpath("//*[@name='#{name}']")
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

      def definition
        self
      end
    end
  end
end
