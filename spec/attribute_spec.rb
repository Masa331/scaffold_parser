RSpec.describe 'attributes' do
  let(:schema) do
    <<-XSD
<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:complexType name="order">
    <xs:sequence>
      <xs:element name="option" type="AttrElement" />
    </xs:sequence>
    <xs:attribute name="version" type="inv:invVersionType" use="required"/>
  </xs:complexType>

  <xs:complexType name="AttrElement">
    <xs:simpleContent>
      <xs:extension base="xs:string">
        <xs:attribute name="value" type="xs:string">
        </xs:attribute>
      </xs:extension>
    </xs:simpleContent>
  </xs:complexType>
</xs:schema>
    XSD
  end

  let(:scaffolds) { Hash[ScaffoldParser.scaffold_to_string(schema)] }

  it 'scaffolds parser for types including attributes' do
    expect(scaffolds['parsers/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser

    def option
      at 'option'
    end

    def option_attributes
      attributes_at 'option'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:option] = option if has? 'option'
      hash[:option_attributes] = option_attributes if has? 'option'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds builder for type including only basic elements' do
    expect(scaffolds['builders/order.rb']).to eq(
      <<-CODE.chomp
module Builders
  class Order
    include ParserCore::BaseBuilder

    def builder
      root = Ox::Element.new(name)
      root = add_attributes_and_namespaces(root)

      root << build_element('option', data[:option], data[:option_attributes]) if data.key? :option

      root
    end
  end
end
      CODE
    )
  end
end
