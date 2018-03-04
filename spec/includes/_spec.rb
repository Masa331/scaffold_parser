RSpec.describe ScaffoldParser do
  it 'includes are parsed correctly' do
    parser_code = parser_for('./spec/includes/schema.xsd', 'order.rb')

    expect(parser_code).to eq_multiline(%{
      |require 'base_element'
      |
      |class Order
      |  include BaseElement
      |
      |  def title
      |    at :title
      |  end
      |
      |  def title2
      |    at :title2
      |  end
      |
      |  def to_h
      |    { title: title,
      |      title2: title2
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })
  end
end
