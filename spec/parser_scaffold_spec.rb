RSpec.describe ScaffoldParser do
  it 'outputs class in module if given' do
    parser_code = parser_for('./order.xsd', 'parsers/order.rb', namespace: 'Something')

    expect(parser_code).to eq_multiline(%{
      |require 'something/base_parser'
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
      |      def to_h
      |        { name: name
      |        }.delete_if { |k, v| v.nil? || v.empty? }
      |      end
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder matches template' do
    builder_code = builder_for('./order.xsd', 'builders/order.rb', namespace: 'Something')

    expect(builder_code).to eq_multiline(%{
      |require 'something/base_builder'
      |
      |module Something
      |  module Builders
      |    class Order
      |      include BaseBuilder
      |
      |      attr_accessor :name
      |
      |      def builder
      |        root = Ox::Element.new(element_name)
      |
      |        root << (Ox::Element.new('name') << name) if name
      |
      |        root
      |      end
      |    end
      |  end
      |end })
  end
end
