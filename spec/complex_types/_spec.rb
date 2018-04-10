RSpec.describe 'complex types' do
  it 'parses complex type allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="souhrnDPHType">
      |    <xs:sequence>
      |      <xs:element name="SeznamDalsiSazby" minOccurs="0">
      |        <xs:complexType>
      |          <xs:sequence>
      |            <xs:element name="DalsiSazba">
      |              <xs:complexType>
      |                <xs:sequence>
      |                  <xs:element name="Popis" minOccurs="0">
      |                  </xs:element>
      |                </xs:sequence>
      |              </xs:complexType>
      |            </xs:element>
      |          </xs:sequence>
      |        </xs:complexType>
      |      </xs:element>
      |    </xs:sequence>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq ''
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
