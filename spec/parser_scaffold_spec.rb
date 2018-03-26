RSpec.describe ScaffoldParser do
  it 'outputs class in module if given' do
    parser_code = parser_for('./order.xsd', 'parsers/order.rb', namespace: 'Something')

    expect(parser_code).to eq_multiline(%{
      |require 'something/parsers/base_parser'
      |require 'something/parsers/customer_type'
      |
      |module Something
      |  module Parsers
      |    class Order
      |      include BaseParser
      |
      |      def name
      |        at 'name'
      |      end
      |
      |      def customer
      |        submodel_at(CustomerType, 'customer')
      |      end
      |
      |      def to_h_with_attrs
      |        hash = HashWithAttributes.new({}, attributes)
      |
      |        hash[:name] = name if has? 'name'
      |        hash[:customer] = customer.to_h_with_attrs if has? 'customer'
      |
      |        hash
      |      end
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder matches template' do
    builder_code = builder_for('./order.xsd', 'builders/order.rb', namespace: 'Something')

    expect(builder_code).to eq_multiline(%{
      |require 'something/builders/base_builder'
      |require 'something/builders/customer_type'
      |
      |module Something
      |  module Builders
      |    class Order
      |      include BaseBuilder
      |
      |      def builder
      |        root = Ox::Element.new(name)
      |        if data.respond_to? :attributes
      |          data.attributes.each { |k, v| root[k] = v }
      |        end
      |
      |        root << build_element('name', data[:name]) if data.key? :name
      |
      |        if data.key? :customer
      |          root << CustomerType.new('customer', data[:customer]).builder
      |        end
      |
      |        root
      |      end
      |    end
      |  end
      |end })
  end
end
