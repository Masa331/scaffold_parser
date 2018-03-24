RSpec.describe 'simple types' do
  it 'parser scaffolder output matches template' do
    parser_code = parser_for('./spec/simple_types/schema.xsd', 'parsers/order.rb')

    expect(parser_code).to eq_multiline(%{
      |require 'parsers/base_parser'
      |
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def name
      |      at :name
      |    end
      |
      |    def title
      |      at :title
      |    end
      |
      |    def total
      |      at :Total
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:name] = name if raw.key? :name
      |      hash[:title] = title if raw.key? :title
      |      hash[:total] = total if raw.key? :Total
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
    builder_code = builder_for('./spec/simple_types/schema.xsd', 'builders/order.rb')

    expect(builder_code).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :name
      |        element = Ox::Element.new('name')
      |        element << attributes[:name] if attributes[:name]
      |        root << element
      |      end
      |
      |      if attributes.key? :title
      |        element = Ox::Element.new('title')
      |        element << attributes[:title] if attributes[:title]
      |        root << element
      |      end
      |
      |      if attributes.key? :total
      |        element = Ox::Element.new('Total')
      |        element << attributes[:total] if attributes[:total]
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end
end
