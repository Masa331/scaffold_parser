module XsdModel
  module Elements
    module BaseElement
      XSD_URI = 'http://www.w3.org/2001/XMLSchema'

      def xsd_prefix
        namespaces.invert[XSD_URI].gsub('xmlns:', '')
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
  module Scaffolders
    class XSD
      class Parser
        attr_reader :name, :node, :extension, :options

        def self.call(name, node, extension, options)
          self.new(name, node, extension, options).call
        end

        def initialize(name, node, extension, options)
          @name = name
          @node = node
          @extension = extension
          @options = options
        end

        def call
          template = ClassTemplate.new(name) do |template|
            template.requires = ['parsers/base_parser']

            methods = node.elements.map { |element| MethodFactory.call(element) }

            methods << MethodTemplate.new('to_h_with_attrs') do |template|
              body = "hash = HashWithAttributes.new({}, attributes)\n\n"

              node.elements.each do |element|
                if element.end_node?
                  body << "hash[:#{element.name.underscore}] = #{element.name.underscore} if has? '#{element.name}'"
                elsif element.submodel_node?
                  body << "hash[:#{element.name.underscore}] = #{element.name.underscore}.to_h_with_attrs if has? '#{element.name}'"
                end
                body << "\n"
              end

              body << "\n"
              body << 'hash'

              template.body = body
            end.to_s

            template.methods = methods
          end.to_s

          ["parsers/#{name.underscore}.rb", template.to_s]
        end
      end
    end
  end
end
