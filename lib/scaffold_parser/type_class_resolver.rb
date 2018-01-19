module ScaffoldParser
  class TypeClassResolver
    class Element
      def initialize(xml)
        @xml = xml
      end

      def no_type?
        @xml['type'].nil?
      end

      def simple_type?
        name == 'SimpleType'
      end

      def custom_type?
        !@xml['type'].nil? && !xs_type?
      end

      def xs_type?
        @xml['type'].start_with?('xs:')
      end

      def type
        @xml['type'].split(':').map(&:capitalize).join
      end

      def name
        t = @xml.name
        t[0] = t[0].upcase
        t
      end
    end

    def self.call(element, model)
      new(element, model).call
    end

    attr_accessor :element, :model

    def initialize(element, model)
      @element = Element.new(element)
      @model = model
    end

    def call
      # tohle mi vubec nepomuze, protoze ten element neni v tomto pripade simple_type ale proste element
      if element.simple_type? || element.no_type?
        ScaffoldParser::Types.const_get element.name
      elsif element.xs_type?
        ScaffoldParser::Types.const_get element.type
      elsif element.custom_type?
        ScaffoldParser::Types::ElementWithUserType
      else
        fail 'nondeducible element type'
      end
    end
  end
end
