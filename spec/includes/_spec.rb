RSpec.describe ScaffoldParser do
  it 'includes are parsed correctly' do
    parser_code = parser_for('./spec/includes/schema.xsd', 'parsers/order.rb')

    expect(parser_code).to eq_multiline(%{
      |require 'base_parser'
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
      |      { title: title,
      |        title2: title2
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
    codes = scaffold_schema('./spec/includes/schema.xsd')

    order_builder = codes['builders/order.rb']
    expect(order_builder).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    attr_accessor :title, :title2
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << (Ox::Element.new('title') << title) if title
      |      root << (Ox::Element.new('title2') << title2) if title2
      |
      |      root
      |    end
      |  end
      |end })
  end
end
