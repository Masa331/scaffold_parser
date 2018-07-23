RSpec.describe 'simple types' do
  let(:schema) do
    <<-XSD
<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:complexType name="order">
    <xs:sequence>
      <xs:element name="name" type="xs:string"/>

      <xs:element name="title" minOccurs="0">
        <xs:simpleType>
          <xs:restriction base="xs:string">
            <xs:maxLength value="10"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>

      <xs:sequence minOccurs="0">
        <xs:element name="Total"/>
      </xs:sequence>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
    XSD
  end

  let(:scaffolds) { Hash[ScaffoldParser.scaffold_to_string(schema)] }

  it 'scaffolds parser for type including only basic elements' do
    expect(scaffolds['parsers/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser

    def name
      at 'name'
    end

    def name_attributes
      attributes_at 'name'
    end

    def title
      at 'title'
    end

    def title_attributes
      attributes_at 'title'
    end

    def total
      at 'Total'
    end

    def total_attributes
      attributes_at 'Total'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:name] = name if has? 'name'
      hash[:name_attributes] = name_attributes if has? 'name'
      hash[:title] = title if has? 'title'
      hash[:title_attributes] = title_attributes if has? 'title'
      hash[:total] = total if has? 'Total'
      hash[:total_attributes] = total_attributes if has? 'Total'

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

      root << build_element('name', data[:name], data[:name_attributes]) if data.key? :name
      root << build_element('title', data[:title], data[:title_attributes]) if data.key? :title
      root << build_element('Total', data[:total], data[:total_attributes]) if data.key? :total

      root
    end
  end
end
      CODE
    )
  end
end
