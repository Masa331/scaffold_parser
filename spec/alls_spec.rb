RSpec.describe 'simple types' do
  it 'all' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |    <xs:all>
      |      <xs:element name="name"/>
      |      <xs:sequence>
      |        <xs:element name="company_name"/>
      |      </xs:sequence>
      |    </xs:all>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def company_name
      |      at 'company_name'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |      hash[:company_name] = company_name if has? 'company_name'
      |
      |      hash
      |    end
      |  end
      |end })
  end
end
