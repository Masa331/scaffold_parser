require 'active_support/all'

module ScaffoldParser
  module NokogiriPatches
    module Element
      def attribute_elements
        if name == 'complexType'
          xpath('xs:sequence/xs:element|xs:sequence/xs:sequence/xs:element')
        elsif name == 'element'
          xpath('xs:complexType/xs:sequence/xs:element')
        else
          fail 'whatever'
        end
      end

      def parent_nodes
        attribute_elements.select(&:parent_type?) + extension_parent_nodes
      end

      def end_nodes
        attribute_elements.select(&:end_type?) + extension_end_nodes
      end

      def list_nodes
        attribute_elements.select(&:list_type?) + extension_list_nodes
      end

      def extension_end_nodes
        extension ? extension.end_nodes : []
      end

      def extension_parent_nodes
        extension ? extension.parent_nodes : []
      end

      def extension_list_nodes
        extension ? extension.list_nodes : []
      end

      def end_type?
        if custom_type?
          type_def&.end_type?
        else
          xs_type? || (no_type? && complex_types.empty? && !complex_type? && !list_type?)
        end
      end

      def parent_type?
        if custom_type?
          type_def&.parent_type?
        else
          (complex_type? || complex_types.any?) && !list_type?
        end
      end

      def list_type?
        if list_element
          max_occure = list_element['maxOccurs']

          max_occure == 'unbounded' || max_occure.to_i > 1
        end
      end

      def list_element_klass
        if list_element
          if list_element['type']
            list_element['type'].camelize
          else
            list_element['name'].camelize
          end
        end
      end

      def list_element_at
        if list_element
          [at_xpath('xs:complexType').to_location, list_element.to_location]
        end
      end

      def to_class_name
        if self['type']
          self['type'].camelize
        else
          to_name.camelize
        end
      end

      def to_file_name
        to_class_name.underscore
      end

      def to_require
        if parent_type?
          to_class_name.underscore
        elsif list_type?
          if list_element
            list_element.to_class_name.underscore
          end
        end
      end

      def to_method_name
        to_name.underscore
      end

      def to_location
        to_name
      end

      def custom_type?
        self['type'].present? && !xs_type?
      end

      def type_def
        find_type(self['type'])
      end

      def list_element
        eles = xpath('xs:complexType/xs:sequence/xs:element')

        if eles.size == 1
          eles.first
        end
      end

      def extension
        elem = at_xpath('xs:complexType/xs:complexContent/xs:extension')

        if elem
          find_type(elem['base'])
        end
      end

      def xs_type?
        self['type'].present? && self['type'].start_with?('xs:')
      end

      private

      def to_name
        if self['name']
          self['name']
        else
          at_xpath('..')['name']
        end
      end

      def complex_types
        xpath('xs:complexType')
      end

      def no_type?
        self['type'].blank?
      end

      def complex_type?
        name == 'complexType'
      end

      def simple_type?
        name == 'simpleType'
      end

      def find_type(name)
        doc = includes.find do |doc|
          doc.at_xpath("//*[@name='#{name}']").present?
        end

        if doc.blank?
          fail "Cant find element definition for '#{name}'. Might be not enough includes?"
        end

        doc.at_xpath("//*[@name='#{name}']")
      end

      def includes
        original_path = ENV['XSD_PATH'] || './'

        collect_includes([], [], self) + [self]
      end

      def collect_includes(collection, names, doc)
        original_path = ENV['XSD_PATH'] || './'

        new_names = doc.xpath('//xs:include').map { |incl| incl['schemaLocation'] }

        (new_names - names).each do |name|
          if names.include? name
            next
          else
            dir = original_path.split('/')
            include_path = (dir + [name]).join('/')

            new_doc = Nokogiri::XML(File.open(include_path))

            collection << new_doc
            names << name

            collect_includes(collection, names, new_doc)
          end
        end

        collection
      end
    end

    module Document
      def parent_nodes
        xpath('xs:schema/xs:complexType|xs:schema/xs:element')
      end

      def list_nodes
        []
      end
    end
  end
end
