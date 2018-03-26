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
      |      at 'title'
      |    end
      |
      |    def title2
      |      at 'title2'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:title] = title if has? 'title'
      |      hash[:title2] = title2 if has? 'title2'
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
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('title', data[:title]) if data.key? :title
      |      root << build_element('title2', data[:title2]) if data.key? :title2
      |
      |      root
      |    end
      |  end
      |end })
  end
end
