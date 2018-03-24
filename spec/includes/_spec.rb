RSpec.describe ScaffoldParser do
  it 'includes are parsed correctly' do
    parser_code = parser_for('./spec/includes/schema.xsd', 'parsers/order.rb')

    expect(parser_code).to eq_multiline(%{
      |require 'parsers/base_parser'
      |
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def title
      |      at :title
      |    end
      |
      |    def title2
      |      at :title2
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:title] = title if raw.key? :title
      |      hash[:title2] = title2 if raw.key? :title2
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
    codes = scaffold_schema('./spec/includes/schema.xsd')

    order_builder = codes['builders/order.rb']
    expect(order_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :title
      |        element = Ox::Element.new('title')
      |        element << attributes[:title] if attributes[:title]
      |        root << element
      |      end
      |
      |      if attributes.key? :title2
      |        element = Ox::Element.new('title2')
      |        element << attributes[:title2] if attributes[:title2]
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end
end
