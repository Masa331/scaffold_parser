RSpec.describe 'schema with duplicate and same named anonymous complex types' do
  let(:schema) do
    <<-XSD
<?xml version="1.0"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:complexType name="order">
    <xs:sequence>
      <xs:element name="buyer">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="name" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>

      <xs:element name="seller">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="name" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="invoice">
    <xs:sequence>
      <xs:element name="buyer">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="name" type="xs:string">
            </xs:element>
            <xs:element name="company_id" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>

      <xs:element name="seller">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="name" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="offer">
    <xs:sequence>
      <xs:element name="buyer">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="name" type="xs:string">
            </xs:element>
            <xs:element name="referer" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="reservation">
    <xs:sequence>
      <xs:element name="buyer">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="name" type="xs:string">
            </xs:element>
            <xs:element name="referer" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
    XSD
  end

  let(:scaffolds) { Hash[ScaffoldParser.scaffold_to_string(schema)] }

  it 'scaffolds parser for order' do
    expect(scaffolds['parsers/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser

    def buyer
      submodel_at(Buyer, 'buyer')
    end

    def seller
      submodel_at(Seller, 'seller')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:buyer] = buyer.to_h if has? 'buyer'
      hash[:seller] = seller.to_h if has? 'seller'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for invoice' do
    expect(scaffolds['parsers/invoice.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Invoice
    include ParserCore::BaseParser

    def buyer
      submodel_at(Buyer2, 'buyer')
    end

    def seller
      submodel_at(Seller, 'seller')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:buyer] = buyer.to_h if has? 'buyer'
      hash[:seller] = seller.to_h if has? 'seller'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for offer' do
    expect(scaffolds['parsers/offer.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Offer
    include ParserCore::BaseParser

    def buyer
      submodel_at(Buyer3, 'buyer')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:buyer] = buyer.to_h if has? 'buyer'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for offer' do
    expect(scaffolds['parsers/reservation.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Reservation
    include ParserCore::BaseParser

    def buyer
      submodel_at(Buyer3, 'buyer')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:buyer] = buyer.to_h if has? 'buyer'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for buyer with only name' do
    expect(scaffolds['parsers/buyer.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Buyer
    include ParserCore::BaseParser

    def name
      at 'name'
    end

    def name_attributes
      attributes_at 'name'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:name] = name if has? 'name'
      hash[:name_attributes] = name_attributes if has? 'name'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for buyer with name and company_id' do
    expect(scaffolds['parsers/buyer2.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Buyer2
    include ParserCore::BaseParser

    def name
      at 'name'
    end

    def name_attributes
      attributes_at 'name'
    end

    def company_id
      at 'company_id'
    end

    def company_id_attributes
      attributes_at 'company_id'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:name] = name if has? 'name'
      hash[:name_attributes] = name_attributes if has? 'name'
      hash[:company_id] = company_id if has? 'company_id'
      hash[:company_id_attributes] = company_id_attributes if has? 'company_id'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for buyer with name and referer' do
    expect(scaffolds['parsers/buyer3.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Buyer3
    include ParserCore::BaseParser

    def name
      at 'name'
    end

    def name_attributes
      attributes_at 'name'
    end

    def referer
      at 'referer'
    end

    def referer_attributes
      attributes_at 'referer'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:name] = name if has? 'name'
      hash[:name_attributes] = name_attributes if has? 'name'
      hash[:referer] = referer if has? 'referer'
      hash[:referer_attributes] = referer_attributes if has? 'referer'

      hash
    end
  end
end
      CODE
    )
  end
end
