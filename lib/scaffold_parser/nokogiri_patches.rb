require 'active_support/all'
module ScaffoldParser
  module NokogiriPatches
    module Element
      def end_nodes
        if self.name == 'complexType'
          xpath('xs:sequence/xs:element').select do |child|
            child.simple_type?
          end
        elsif  self.name == 'element'
          xpath('xs:complexType/xs:sequence/xs:element').select do |child|
            child.simple_type?
          end
        else
          fail 'whatever'
        end
      end

      def simple_type?
        xtype = self['type']

        if name == 'simpleType'
          true
        elsif name == 'complexType'
          false
        elsif xtype.blank? && xpath('xs:complexType').empty?
          true
        elsif xtype.blank? && xpath('xs:complexType').any?
          false
        elsif xtype.present? && xtype.start_with?('xs:')
          true
        else
          type_def = find_type(xtype)

          type_def.simple_type?
        end
      end

      def parent_nodes
        if self.name == 'complexType'
          xpath('xs:sequence/xs:element').select do |child|
            child.parent_type?
          end
        elsif  self.name == 'element'
          xpath('xs:complexType/xs:sequence/xs:element').select do |child|
            child.parent_type?
          end
        else
          fail 'whatever'
        end
      end

      def parent_type?
        if name == 'complexType'
          true
        elsif self['type'].blank? && xpath('xs:complexType').any?
          true
        elsif self['type'].blank? && xpath('xs:complexType').none?
          false
        elsif self['type'].present? && self['type'].start_with?('xs:')
          false
        else
          type_def = find_type(self['type'])

          type_def.parent_type?
        end
      end

      def to_class_name
        if self['type']
          self['type'].classify
        elsif self['name']
          self['name'].classify
        else
          at_xpath('..')['name'].classify
        end
      end

      def to_file_name
        to_class_name.underscore
      end

      def to_require
        # require 'pry'; binding.pry
        to_class_name.underscore
      end

      def to_method_name
        if self['name']
          self['name'].underscore
        else
          at_xpath('..')['name'].underscore
        end
      end

      def to_location
        if self['name']
          self['name']
        else
          at_xpath('..')['name']
        end
      end

      private

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
