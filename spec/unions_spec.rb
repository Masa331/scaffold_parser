RSpec.describe 'unions' do
  it 'parses union allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |    <xs:sequence>
      |      <xs:element name="flag" minOccurs="0">
      |        <xs:simpleType>
      |          <xs:union memberTypes="type1 type2"/>
      |        </xs:simpleType>
      |      </xs:element>
      |    </xs:sequence>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include ParserCore::BaseParser
      |
      |    def flag
      |      at 'flag'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = ParserCore::HashWithAttributes.new({}, attributes)
      |
      |      hash[:flag] = flag if has? 'flag'
      |
      |      hash
      |    end
      |  end
      |end })
  end
end
