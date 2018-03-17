RSpec.describe ScaffoldParser do
  it 'outputs class in module if given' do
    parser_code = parser_for('./order.xsd', 'parsers/order.rb', namespace: 'Something')

    expect(parser_code).to eq_multiline(%{
      |require 'something/base_parser'
      |
      |module Something
      |  class Order
      |    include BaseParser
      |
      |    def name
      |      at :name
      |    end
      |
      |    def to_h
      |      { name: name
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })
  end
end
