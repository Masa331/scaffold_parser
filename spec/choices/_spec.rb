RSpec.describe 'choices' do
  it 'parser scaffolder matches template' do
    parser_code = parser_for('./spec/choices/schema.xsd', 'parsers/order.rb')

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
      |    def company_name
      |      at :company_name
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:name] = name if raw.key? :name
      |      hash[:company_name] = company_name if raw.key? :company_name
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder matches template' do
    builder_code = builder_for('./spec/choices/schema.xsd', 'builders/order.rb')

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
      |      if attributes.key? :company_name
      |        element = Ox::Element.new('company_name')
      |        element << attributes[:company_name] if attributes[:company_name]
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end
end
