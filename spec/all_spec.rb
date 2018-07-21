RSpec.describe 'simple types' do
  it 'all' do
    schema =
      <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:complexType name="order">
          <xs:all>
            <xs:element name="name"/>
            <xs:sequence>
              <xs:element name="company_name"/>
            </xs:sequence>
          </xs:all>
        </xs:complexType>
      </xs:schema>
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq(
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
end
