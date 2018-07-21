RSpec.describe 'choices' do
  it 'choice inside complexType' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      <xs:complexType name="order">
        <xs:sequence>
          <xs:element name="customer_name">
          </xs:element>
          <xs:choice>
            <xs:sequence>
              <xs:element name="id"/>
              <xs:element name="vat_id"/>
            </xs:sequence>
            <xs:element name="customer_info">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="address">
                  </xs:element>
                  <xs:element name="email">
                  </xs:element>
                </xs:sequence>
              </xs:complexType>
            </xs:element>
          </xs:choice>
        </xs:sequence>
      </xs:complexType>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser

    def customer_name
      at 'customer_name'
    end

    def customer_name_attributes
      attributes_at 'customer_name'
    end

    def id
      at 'id'
    end

    def id_attributes
      attributes_at 'id'
    end

    def vat_id
      at 'vat_id'
    end

    def vat_id_attributes
      attributes_at 'vat_id'
    end

    def customer_info
      submodel_at(CustomerInfo, 'customer_info')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:customer_name] = customer_name if has? 'customer_name'
      hash[:customer_name_attributes] = customer_name_attributes if has? 'customer_name'
      hash[:id] = id if has? 'id'
      hash[:id_attributes] = id_attributes if has? 'id'
      hash[:vat_id] = vat_id if has? 'vat_id'
      hash[:vat_id_attributes] = vat_id_attributes if has? 'vat_id'
      hash[:customer_info] = customer_info.to_h if has? 'customer_info'

      hash
    end
  end
end
      CODE
    )
  end

  let(:schema) do
    <<-XSD
<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:complexType name="order">
    <xs:sequence>
      <xs:choice>
        <xs:sequence minOccurs="0">
          <xs:element name="name" type="xs:string"/>
        </xs:sequence>

        <xs:element name="company_name" type="xs:string"/>
      </xs:choice>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
    XSD
  end
  let(:scaffolds) { Hash[ScaffoldParser.scaffold_to_string(schema)] }

  it 'scaffolds parser for type which includes choice' do
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

    def company_name
      at 'company_name'
    end

    def company_name_attributes
      attributes_at 'company_name'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:name] = name if has? 'name'
      hash[:name_attributes] = name_attributes if has? 'name'
      hash[:company_name] = company_name if has? 'company_name'
      hash[:company_name_attributes] = company_name_attributes if has? 'company_name'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds builder for type which includes choice' do
    expect(scaffolds['builders/order.rb']).to eq(
      <<-CODE.chomp
module Builders
  class Order
    include ParserCore::BaseBuilder

    def builder
      root = Ox::Element.new(name)
      if data.key? :attributes
        data[:attributes].each { |k, v| root[k] = v }
      end

      root << build_element('name', data[:name], data[:name_attributes]) if data.key? :name
      root << build_element('company_name', data[:company_name], data[:company_name_attributes]) if data.key? :company_name

      root
    end
  end
end
      CODE
    )
  end
end
