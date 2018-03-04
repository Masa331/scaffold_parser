RSpec.describe ScaffoldParser do
  it 'outputs class in module if given' do
    parser_code = parser_for('./order.xsd', 'order.rb', namespace: 'Something')

    expect(parser_code).to eq_multiline(%{
      |require 'something/base_element'
      |
      |module Something
      |  class Order
      |    include BaseElement
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
