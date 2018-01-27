require 'active_support/all'

module ScaffoldParser
  module NokogiriPatches
    module Element
      def attribute_elements
        if name == 'complexType'
          xpath('xs:sequence/xs:element')
        elsif name == 'element'
          xpath('xs:complexType/xs:sequence/xs:element')
        else
          fail 'whatever'
        end
      end

      def parent_nodes
        attribute_elements.select do |child|
          child.parent_type?
        end
      end

      def end_nodes
        attribute_elements.select do |child|
          child.end_type?
        end
      end

      def end_type?
        if custom_type?
          type_def&.end_type?
        else
          xs_type? || (no_type? && complex_types.empty? && !complex_type?)
        end
      end

      def parent_type?
        if custom_type?
          type_def&.parent_type?
        else
          complex_type? || complex_types.any?
        end
      end

      def to_class_name
        if self['type']
          self['type'].classify
        else
          to_name.classify
        end
      end

      def to_file_name
        to_class_name.underscore
      end

      def to_require
        to_class_name.underscore
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

      def xs_type?
        self['type'].present? && self['type'].start_with?('xs:')
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
          fail "Cant find element definition for #{node.name}(#{node.type}). Might be not enough includes?"
        end

        doc.at_xpath("//*[@name='#{name}']")
      end

      def includes
        original_path = './spec/fixtures/xsd/'

        incls = xpath('//xs:include').map { |incl| incl['schemaLocation'] }

        docs = [self] + incls.map do |include_path|
          dir = original_path.split('/')
          include_path = (dir + [include_path]).join('/')
          Nokogiri::XML(File.open(include_path))
        end

        docs
      end
    end

    module Document
      # def end_nodes
      #   xpath('.//xs:simpleType')
      # end

      def parent_nodes
        xpath('xs:schema/xs:complexType')
      end
    end
  end
end
