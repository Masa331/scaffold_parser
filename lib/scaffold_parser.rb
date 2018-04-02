require 'xsd_model'

require 'active_support/all'

require 'scaffold_parser/template_utils'
require 'scaffold_parser/class_template'
require 'scaffold_parser/base_method_template'
require 'scaffold_parser/at_method_template'
require 'scaffold_parser/submodel_method_template'
require 'scaffold_parser/list_method_template'
require 'scaffold_parser/string_list_method_template'
require 'scaffold_parser/proxy_list_method_template'
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

      def no_type?
        attributes['type'].nil?
      end

      def type
        attributes['type']
      end

      def has_type?
        !attributes['type'].nil?
      end

      def basic_xsd_type?
        type && type.start_with?("#{xsd_prefix}:")
      end

      def empty?
        children.empty?
      end

      def has_base?
        !attributes['base'].nil?
      end

      def has_name?
        !attributes['name'].nil?
      end
    end

    class Extension
      def basic_xsd_extension?
        base.start_with?("#{xsd_prefix}:")
      end

      def base
        attributes['base']
      end
    end

    class Schema
      def complex_types
        children.select { |child| child.is_a? Elements::ComplexType }
      end

      def simple_types
        children.select { |child| child.is_a? Elements::SimpleType }
      end

      def elements
        children.select { |child| child.is_a? Elements::Element }
      end
    end

    class SimpleType
      def name
        attributes['name']
      end
    end

    class ComplexType
      def name
        attributes['name']
      end

      def elements
        children.select { |child| child.is_a? Elements::Element }
      end

      def base
        attributes['base']
      end
    end

    class Element
      def name
        attributes['name']
      end

      def max_occurs
        value = attributes['maxOccurs']

        case value
        when 'unbounded'
          then Float::INFINITY
        when String
          then value.to_i
        when nil
          then 1
        end
      end

      # take se nehodi uz do xsd_model asi
      def somehow_multiple?
        multiple? || multiple_proxy?
      end

      def multiple?
        max_occurs > 1
      end

      def multiple_proxy?
        children.size == 1 && children.last.multiple?
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
    collect_only = -> (e) { ['schema', 'document', 'element', 'extension', 'complexType', 'simpleType', 'include', 'import'].include?(e.name) }
    doc = XsdModel.parse(File.read(path), { collect_only: collect_only })

    Scaffolders::XSD.call(doc, options)
  end
end
