module ScaffoldParser
  class MethodFactory
    class UnknownNodeType < StandardError; end

    attr_reader :element

    def self.call(element)
      new(element).call
    end

    def initialize(element)
      @element = element
    end

    def call
      if element.end_node?
        end_node_method
      elsif element.submodel_node?
        submodel_node_method
      elsif element.is_a?(XsdModel::Elements::Element) && element.multiple?
        array_node_method
      elsif (element.children.size == 1) && element.children.last.is_a?(XsdModel::Elements::Element) && element.children.last.multiple?
        array_node_method2
      else
        fail UnknownNodeType
      end
    end

    private

    def end_node_method
      MethodTemplate.new(element.name.underscore) do |template|
        template.body = "at '#{element.name}'"
      end.to_s
    end

    def submodel_node_method
      if element.custom_type?
        MethodTemplate.new(element.name.underscore) do |template|
          template.body = "submodel_at(#{element.type.camelize}, '#{element.name}')"
        end.to_s
      else
        MethodTemplate.new(element.name.underscore) do |template|
          template.body = "submodel_at(#{element.name.camelize}, '#{element.name}')"
        end.to_s
      end
    end

    def array_node_method
      MethodTemplate.new(element.name.underscore) do |template|
        template.body = "zble"
      end.to_s
    end

    def array_node_method2
      MethodTemplate.new(element.name.underscore) do |template|
        template.body = "zble"
      end.to_s
    end
  end
end
