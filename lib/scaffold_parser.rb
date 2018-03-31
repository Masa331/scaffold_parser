require 'xsd_model'

require 'active_support/all'

require 'scaffold_parser/template_utils'
require 'scaffold_parser/class_template'
require 'scaffold_parser/base_method_template'
require 'scaffold_parser/at_method_template'
require 'scaffold_parser/submodel_method_template'
require 'scaffold_parser/list_method_template'
require 'scaffold_parser/string_list_method_template'
require 'scaffold_parser/method_factory'

require 'scaffold_parser/scaffolders/xsd'

module XsdModel
  module Elements
    module BaseElement
      XSD_URI = 'http://www.w3.org/2001/XMLSchema'

      def xsd_prefix
        namespaces.invert[XSD_URI].gsub('xmlns:', '')
      end

      def element_name
        self.class.name.demodulize.underscore
      end
    end

    class Extension
      def extending_basic_xsd_type?
        base.start_with?("#{xsd_prefix}:")
      end

      def base
        attributes['base'].value
      end
    end

    class ComplexType
      def name
        attributes['name']&.value
      end

      def elements
        children.select { |child| child.is_a? Elements::Element }
      end
    end

    class Element
      def type
        attributes['type']&.value
      end

      def name
        attributes['name'].value
      end

      def max_occurs
        value = attributes['maxOccurs']&.value

        # if value
        #   attr.value.to_i
        # else
        case value
        when 'unbounded'
          then Float::INFINITY
        when String
          then value.to_i
        when nil
          then 1
        end
      end

      def multiple?
        max_occurs > 1
      end

      def basic_xsd_type?
        type && type.start_with?("#{xsd_prefix}:")
      end

      def custom_type?
        type && !type.start_with?("#{xsd_prefix}:")
      end

      # TODO: tohle nedavat do xsd_modelu ale nechat tady
      # def anonymous_type?
      #   # type.nil? && children.last.is_a?(Elements::ComplexType)
      #   type.nil? && children.any?
      # end
      # TODO: tohle nedavat do xsd_modelu ale nechat tady
      def end_node?
        (type.nil? || basic_xsd_type?) && children.empty?
      end
      # TODO: tohle nedavat do xsd_modelu ale nechat tady
      def submodel_node?
        custom_type?
      end
      # TODO: tohle nedavat do xsd_modelu ale nechat tady
      def elements
        children.select { |child| child.is_a? Elements::Element }
      end
    end
  end
end

module ScaffoldParser
  def self.scaffold(path, options = {})
    unless Dir.exists?('./tmp/')
      Dir.mkdir('./tmp/')
      puts './tmp/ directory created'
    end

    unless Dir.exists?('./tmp/builders')
      Dir.mkdir('./tmp/builders')
      puts './tmp/builders directory created'
    end

    unless Dir.exists?('./tmp/parsers')
      Dir.mkdir('./tmp/parsers')
      puts './tmp/parsers directory created'
    end

    scaffold_to_string(path, options).each do |path, content|
      complete_path = path.prepend('./tmp/')

      puts "Writing out #{complete_path}" if options[:verbose]

      File.open(complete_path, 'wb') { |f| f.write content }
    end
  end

  def self.scaffold_to_string(path, options = {})
    collect_only = -> (e) { ['schema', 'document', 'element', 'extension', 'complexType'].include?(e.name) }
    # ignore = -> (e) { e.name == 'complexType' && e['name'].nil? }
    # doc = XsdModel.parse(File.read(path), { collect_only: collect_only, ignore: ignore })
    doc = XsdModel.parse(File.read(path), { collect_only: collect_only })

    Scaffolders::XSD.call(doc, options)
  end
end
