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
      |        at :name
      |      end
      |
      |      def customer
      |        submodel_at(CustomerType, :customer)
      |      end
      |
      |      def to_h
      |        hash = {}
      |
      |        hash[:name] = name if raw.key? :name
      |        hash[:customer] = customer.to_h if raw.key? :customer
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
      |        root = Ox::Element.new(element_name)
      |
      |        if attributes.key? :name
      |          element = Ox::Element.new('name')
      |          element << attributes[:name] if attributes[:name]
      |          root << element
      |        end
      |
      |        if attributes.key? :customer
      |          root << CustomerType.new(attributes[:customer], 'customer').builder
      |        end
      |
      |        root
      |      end
      |    end
      |  end
      |end })
  end
end
