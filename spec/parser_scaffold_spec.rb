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
      |        { name: name,
      |          customer: customer.to_h
      |        }.delete_if { |k, v| v.nil? || v.empty? }
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
      |      attr_accessor :name, :customer
      |
      |      def builder
      |        root = Ox::Element.new(element_name)
      |
      |        root << (Ox::Element.new('name') << name) if name
      |        root << CustomerType.new(customer, 'customer').builder if customer
      |
      |        root
      |      end
      |    end
      |  end
      |end })
  end
end
