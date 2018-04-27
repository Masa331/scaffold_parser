RSpec.describe 'simple types' do
  it 'parses complex type allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:element name="konfigurace" minOccurs="0">
      |    <xs:complexType>
      |      <xs:group ref="konfigurace" minOccurs="0"/>
      |    </xs:complexType>
      |  </xs:element>
      |
      |  <xs:group name="konfigurace">
      |    <xs:sequence>
      |      <xs:element name="flag">
      |    </xs:sequence>
      |  </xs:group>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/konfigurace.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Konfigurace
      |    include ParserCore::BaseParser
      |    include Groups::Konfigurace
      |
      |    def to_h_with_attrs
      |      hash = ParserCore::HashWithAttributes.new({}, attributes)
      |
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })

    scaffold = Hash[scaffolds]['parsers/groups/konfigurace.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  module Groups
      |    module Konfigurace
      |      def flag
      |        at 'flag'
      |      end
      |
      |      def to_h_with_attrs
      |        hash = ParserCore::HashWithAttributes.new({}, attributes)
      |
      |        hash[:flag] = flag if has? 'flag'
      |
      |        hash
      |      end
      |    end
      |  end
      |end })
  end
end
