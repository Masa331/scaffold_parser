RSpec.describe 'complex types' do
  it 'complex type referencing type from same namespace with full prefix' do
    schema = <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xsd:schema
           xmlns:xsd="http://www.w3.org/2001/XMLSchema"
           xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
           xmlns="http://www.stormware.cz/schema/version_2/invoice.xsd"
           targetNamespace="http://www.stormware.cz/schema/version_2/invoice.xsd"
           elementFormDefault="qualified">

        <xsd:complexType name="invoiceType">
          <xsd:sequence>
            <xsd:element name="invoiceHeader" type="inv:invoiceHeaderType"/>
          </xsd:sequence>
        </xsd:complexType>

        <xsd:complexType name="invoiceHeaderType">
          <xsd:all>
            <xsd:element name="intNote" type="xsd:string"/>
          </xsd:all>
        </xsd:complexType>
      </xsd:schema>
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/inv/invoice_type.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  module Inv
    class InvoiceType
      include ParserCore::BaseParser

      def invoice_header
        submodel_at(Inv::InvoiceHeaderType, 'inv:invoiceHeader')
      end

      def to_h
        hash = {}
        hash[:attributes] = attributes

        hash[:invoice_header] = invoice_header.to_h if has? 'inv:invoiceHeader'

        hash
      end
    end
  end
end
      CODE
    )
  end

  it 'complex type with namespaces' do
    schema = <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
        xmlns="http://www.stormware.cz/schema/version_2/invoice.xsd"
        targetNamespace="http://www.stormware.cz/schema/version_2/invoice.xsd"
        elementFormDefault="qualified">
        <xs:element name="order" type="orderType"/>

        <xs:complexType name="orderType">
          <xs:sequence>
            <xs:element name="customer">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="name"/>
                  <xs:element name="address"/>
                </xs:sequence>
              </xs:complexType>
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:schema>
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/inv/order_type.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  module Inv
    class OrderType
      include ParserCore::BaseParser

      def customer
        submodel_at(Inv::Customer, 'inv:customer')
      end

      def to_h
        hash = {}
        hash[:attributes] = attributes

        hash[:customer] = customer.to_h if has? 'inv:customer'

        hash
      end
    end
  end
end
      CODE
    )

    scaffold = Hash[scaffolds]['parsers/inv/customer.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  module Inv
    class Customer
      include ParserCore::BaseParser

      def name
        at 'inv:name'
      end

      def name_attributes
        attributes_at 'inv:name'
      end

      def address
        at 'inv:address'
      end

      def address_attributes
        attributes_at 'inv:address'
      end

      def to_h
        hash = {}
        hash[:attributes] = attributes

        hash[:name] = name if has? 'inv:name'
        hash[:name_attributes] = name_attributes if has? 'inv:name'
        hash[:address] = address if has? 'inv:address'
        hash[:address_attributes] = address_attributes if has? 'inv:address'

        hash
      end
    end
  end
end
      CODE
    )

    scaffold = Hash[scaffolds]['builders/inv/order_type.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Builders
  module Inv
    class OrderType
      include ParserCore::BaseBuilder

      def builder
        root = Ox::Element.new(name)
        root = add_attributes_and_namespaces(root)

        if data.key? :customer
          root << Inv::Customer.new('inv:customer', data[:customer]).builder
        end

        root
      end
    end
  end
end
      CODE
    )
  end

  it 'model names are not pluralized' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:element name="order">
          <xs:complexType>
            <xs:complexContent>
              <xs:extension base="seznamType">
                <xs:sequence>
                  <xs:element name="KmKarta" maxOccurs="unbounded">
                    <xs:complexType>
                      <xs:complexContent>
                        <xs:extension base="kmKartaType"/>
                      </xs:complexContent>
                    </xs:complexType>
                  </xs:element>
                </xs:sequence>
              </xs:extension>
            </xs:complexContent>
          </xs:complexType>
        </xs:element>
      
        <xs:complexType name="seznamType">
          <xs:sequence>
            <xs:element name="title" type"xs:string"/>
          </xs:sequence>
        </xs:complexType>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  class Order < SeznamType
    include ParserCore::BaseParser

    def km_karta
      array_of_at(KmKarta, ['KmKarta'])
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:km_karta] = km_karta.map(&:to_h) if has? 'KmKarta'

      hash
      super.merge(hash)
    end
  end
end
      CODE
    )
  end

  it 'sequence inside a sequence inside i sequence... i know..' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:complexType name="order">
          <xs:sequence>
            <xs:element name="name"/>
            <xs:sequence>
              <xs:element name="company_name"/>
              <xs:element name="company_address"/>
            </xs:sequence>
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

    def company_address
      at 'company_address'
    end

    def company_address_attributes
      attributes_at 'company_address'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:name] = name if has? 'name'
      hash[:name_attributes] = name_attributes if has? 'name'
      hash[:company_name] = company_name if has? 'company_name'
      hash[:company_name_attributes] = company_name_attributes if has? 'company_name'
      hash[:company_address] = company_address if has? 'company_address'
      hash[:company_address_attributes] = company_address_attributes if has? 'company_address'

      hash
    end
  end
end
      CODE
    )
  end

  it 'empty complex type' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:complexType name="order">
          <xs:sequence>
            <xs:element name="ISDOC">
              <xs:annotation>
                <xs:documentation>some comment..</xs:documentation>
              </xs:annotation>
              <xs:complexType>
                <xs:attribute name="OznacDok" use="optional">
                  <xs:annotation>
                    <xs:documentation>Označení dokumentu, kterým dal příjemce vystaviteli souhlas s elektronickou formou faktury</xs:documentation>
                  </xs:annotation>
                </xs:attribute>
                <xs:attribute name="IdZboziKupujici" use="optional"/>
                <xs:attribute name="Katalog" use="optional"/>
                <xs:attribute name="UzivCode" use="optional"/>
              </xs:complexType>
            </xs:element>
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

    def isdoc
      at 'ISDOC'
    end

    def isdoc_attributes
      attributes_at 'ISDOC'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:isdoc] = isdoc if has? 'ISDOC'
      hash[:isdoc_attributes] = isdoc_attributes if has? 'ISDOC'

      hash
    end
  end
end
      CODE
    )
  end

  it 'parses complex type allright' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:complexType name="souhrnDPHType">
          <xs:sequence>
            <xs:element name="SeznamDalsiSazby">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="DalsiSazba" type="someType">
                  </xs:element>
                </xs:sequence>
              </xs:complexType>
            </xs:element>
          </xs:sequence>
        </xs:complexType>
        <xs:complexType name="someType">
          <xs:sequence>
            <xs:element name="rate">
          </xs:sequence>
        </xs:complexType>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/seznam_dalsi_sazby.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  class SeznamDalsiSazby
    include ParserCore::BaseParser

    def dalsi_sazba
      submodel_at(SomeType, 'DalsiSazba')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:dalsi_sazba] = dalsi_sazba.to_h if has? 'DalsiSazba'

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
      <xs:element name="currency">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="currencyId" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>

      <xs:element name="customer" type="customerType"/>

      <xs:sequence minOccurs="0">
        <xs:element name="customer2" type="customerType"/>
      </xs:sequence>
    </xs:sequence>
  </xs:complexType>

  <xs:complexType name="customerType">
    <xs:sequence>
      <xs:element name="name">
        <xs:simpleType>
          <xs:restriction base="xs:string">
            <xs:maxLength value="4"/>
          </xs:restriction>
        </xs:simpleType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
    XSD
  end

  let(:scaffolds) { Hash[ScaffoldParser.scaffold_to_string(schema)] }

  it 'scaffolds parser for type with various complex types' do
    expect(scaffolds['parsers/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser

    def currency
      submodel_at(Currency, 'currency')
    end

    def customer
      submodel_at(CustomerType, 'customer')
    end

    def customer2
      submodel_at(CustomerType, 'customer2')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:currency] = currency.to_h if has? 'currency'
      hash[:customer] = customer.to_h if has? 'customer'
      hash[:customer2] = customer2.to_h if has? 'customer2'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for subtype' do
    expect(scaffolds['parsers/currency.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Currency
    include ParserCore::BaseParser

    def currency_id
      at 'currencyId'
    end

    def currency_id_attributes
      attributes_at 'currencyId'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:currency_id] = currency_id if has? 'currencyId'
      hash[:currency_id_attributes] = currency_id_attributes if has? 'currencyId'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for type including simpleType' do
    expect(scaffolds['parsers/customer_type.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class CustomerType
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

  it 'scaffolds builder for type with various complex types' do
    expect(scaffolds['builders/order.rb']).to eq(
      <<-CODE.chomp
module Builders
  class Order
    include ParserCore::BaseBuilder

    def builder
      root = Ox::Element.new(name)
      root = add_attributes_and_namespaces(root)

      if data.key? :currency
        root << Currency.new('currency', data[:currency]).builder
      end
      if data.key? :customer
        root << CustomerType.new('customer', data[:customer]).builder
      end
      if data.key? :customer2
        root << CustomerType.new('customer2', data[:customer2]).builder
      end

      root
    end
  end
end
      CODE
    )
  end

  it 'scaffolds builder for type with various complex types' do
    expect(scaffolds['builders/currency.rb']).to eq(
      <<-CODE.chomp
module Builders
  class Currency
    include ParserCore::BaseBuilder

    def builder
      root = Ox::Element.new(name)
      root = add_attributes_and_namespaces(root)

      root << build_element('currencyId', data[:currency_id], data[:currency_id_attributes]) if data.key? :currency_id

      root
    end
  end
end
      CODE
    )
  end

  it 'scaffolds builder for type with various complex types' do
    expect(scaffolds['builders/customer_type.rb']).to eq(
      <<-CODE.chomp
module Builders
  class CustomerType
    include ParserCore::BaseBuilder

    def builder
      root = Ox::Element.new(name)
      root = add_attributes_and_namespaces(root)

      root << build_element('name', data[:name], data[:name_attributes]) if data.key? :name

      root
    end
  end
end
      CODE
    )
  end
end
