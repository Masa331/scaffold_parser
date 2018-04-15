RSpec.describe 'complex types' do
  it 'sequence inside a sequence inside i sequence... i know..' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |    <xs:sequence>
      |      <xs:element name="name"/>
      |      <xs:sequence>
      |        <xs:element name="company_name"/>
      |        <xs:element name="company_address"/>
      |      </xs:sequence>
      |    </xs:sequence>
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
      |    def company_address
      |      at 'company_address'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |      hash[:company_name] = company_name if has? 'company_name'
      |      hash[:company_address] = company_address if has? 'company_address'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'empty complex type' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="list_type"/>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/list_type.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class ListType
      |    include BaseParser
      |  end
      |end })
  end

  it 'empty complex type' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |    <xs:sequence>
      |      <xs:element name="ISDOC">
      |        <xs:annotation>
      |          <xs:documentation>some comment..</xs:documentation>
      |        </xs:annotation>
      |        <xs:complexType>
      |          <xs:attribute name="OznacDok" use="optional">
      |            <xs:annotation>
      |              <xs:documentation>Označení dokumentu, kterým dal příjemce vystaviteli souhlas s elektronickou formou faktury</xs:documentation>
      |            </xs:annotation>
      |          </xs:attribute>
      |          <xs:attribute name="IdZboziKupujici" use="optional"/>
      |          <xs:attribute name="Katalog" use="optional"/>
      |          <xs:attribute name="UzivCode" use="optional"/>
      |        </xs:complexType>
      |      </xs:element>
      |    </xs:sequence>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def isdoc
      |      at 'ISDOC'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:isdoc] = isdoc if has? 'ISDOC'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'parses complex type allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="souhrnDPHType">
      |    <xs:sequence>
      |      <xs:element name="SeznamDalsiSazby">
      |        <xs:complexType>
      |          <xs:sequence>
      |            <xs:element name="DalsiSazba" type="someType">
      |            </xs:element>
      |          </xs:sequence>
      |        </xs:complexType>
      |      </xs:element>
      |    </xs:sequence>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/seznam_dalsi_sazby.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class SeznamDalsiSazby
      |    include BaseParser
      |
      |    def dalsi_sazba
      |      submodel_at(SomeType, 'DalsiSazba')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:dalsi_sazba] = dalsi_sazba.to_h_with_attrs if has? 'DalsiSazba'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  let(:scaffolds) { scaffold_schema('./spec/complex_types/schema.xsd') }

  it 'scaffolds parser for type with various complex types' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def currency
      |      submodel_at(Currency, 'currency')
      |    end
      |
      |    def customer
      |      submodel_at(CustomerType, 'customer')
      |    end
      |
      |    def customer2
      |      submodel_at(CustomerType, 'customer2')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:currency] = currency.to_h_with_attrs if has? 'currency'
      |      hash[:customer] = customer.to_h_with_attrs if has? 'customer'
      |      hash[:customer2] = customer2.to_h_with_attrs if has? 'customer2'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for subtype' do
    expect(scaffolds['parsers/currency.rb']).to eq_multiline(%{
      |module Parsers
      |  class Currency
      |    include BaseParser
      |
      |    def currency_id
      |      at 'currencyId'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:currency_id] = currency_id if has? 'currencyId'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for type including simpleType' do
    expect(scaffolds['parsers/customer_type.rb']).to eq_multiline(%{
      |module Parsers
      |  class CustomerType
      |    include BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type with various complex types' do
    expect(scaffolds['builders/order.rb']).to eq_multiline(%{
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      if data.key? :currency
      |        root << Currency.new('currency', data[:currency]).builder
      |      end
      |      if data.key? :customer
      |        root << CustomerType.new('customer', data[:customer]).builder
      |      end
      |      if data.key? :customer2
      |        root << CustomerType.new('customer2', data[:customer2]).builder
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type with various complex types' do
    expect(scaffolds['builders/currency.rb']).to eq_multiline(%{
      |module Builders
      |  class Currency
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('currencyId', data[:currency_id]) if data.key? :currency_id
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type with various complex types' do
    expect(scaffolds['builders/customer_type.rb']).to eq_multiline(%{
      |module Builders
      |  class CustomerType
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('name', data[:name]) if data.key? :name
      |
      |      root
      |    end
      |  end
      |end })
  end
end
