module ScaffoldParser
  class TypeClassResolver
    class Decorator
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
        _, type = @xml['type'].split(':')

        "Xs#{type.classify}"
      end

      def name
        t = @xml.name
        t[0] = t[0].upcase
        t
      end
    end

    def self.call(element)
      new(element).call
    end

    attr_accessor :decorator, :element

    def initialize(element)
      @element = element
      @decorator = Decorator.new(element)
    end

    def call
      if decorator.simple_type? || decorator.no_type?

        # if decorator.name == 'Xs:element'
        #   require 'pry'; binding.pry
        # end
        #
        # if element.name == 'element'
        #   require 'pry'; binding.pry
        # end

        ScaffoldParser::Types.const_get(decorator.name).call(element)
      elsif decorator.xs_type?
        ScaffoldParser::Types.const_get(decorator.type).call(element)
      elsif decorator.custom_type?
        ScaffoldParser::Types::ElementWithUserType.call(element)
      else
        fail 'nondeducible element type'
      end
    end
  end
end
