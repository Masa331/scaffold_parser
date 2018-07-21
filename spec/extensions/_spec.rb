RSpec.describe ScaffoldParser do
  it 'extension from namespaced element' do
    schema = <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xsd:schema
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns:ord="order"
        xmlns="order"
        targetNamespace="order"
        elementFormDefault="qualified">

        <xsd:complexType name="numberRequested">
          <xsd:simpleContent>
            <xsd:extension base="ord:baseElement">
            </xsd:extension>
          </xsd:simpleContent>
        </xsd:complexType>

        <xsd:complexType name="baseElement">
          <xsd:all>
            <xsd:element name="numberRequested"/>
          </xsd:all>
        </xsd:complexType>
      </xsd:schema>
      XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/ord/number_requested.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  module Ord
      |    class NumberRequested < Ord::BaseElement
      |      include ParserCore::BaseParser
      |    end
      |  end
      |end })
  end

  it 'extension from custom simple type' do
    schema = <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <xsd:complexType name="numberADType">
          <xsd:all>
            <xsd:element name="numberRequested">
              <xsd:complexType>
                <xsd:simpleContent>
                  <xsd:extension base="typ:string20">
                  </xsd:extension>
                </xsd:simpleContent>
              </xsd:complexType>
            </xsd:element>
          </xsd:all>
        </xsd:complexType>
      </xsd:schema> })
      XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/number_ad_type.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class NumberADType
      |    include ParserCore::BaseParser
      |
      |    def number_requested
      |      at 'numberRequested'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:number_requested] = number_requested if has? 'numberRequested'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'parses elements with extension' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |   <xs:complexContent>
      |     <xs:extension base="baseElement">
      |       <xs:sequence>
      |         <xs:element name="name"/>
      |       </xs:sequence>
      |     </xs:extension>
      |   </xs:complexContent>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include ParserCore::BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:name] = name if has? 'name'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'parses elements with extension' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |   <xs:complexContent>
      |     <xs:extension base="baseElement">
      |       <xs:sequence>
      |         <xs:element name="name"/>
      |       </xs:sequence>
      |     </xs:extension>
      |   </xs:complexContent>
      |  </xs:complexType>
      |
      |  <xs:complexType name="baseElement">
      |    <xs:sequence>
      |      <xs:element name="title" type"xs:string"/>
      |    </xs:sequence>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order < BaseElement
      |    include ParserCore::BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:name] = name if has? 'name'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      |end })
  end

  let(:scaffolds) { scaffold_schema('./spec/extensions/schema.xsd') }

  it 'scaffolds parser for type with various extensions' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include ParserCore::BaseParser
      |
      |    def customer
      |      submodel_at(Customer, 'customer')
      |    end
      |
      |    def company
      |      submodel_at(Company, 'company')
      |    end
      |
      |    def seller
      |      submodel_at(Seller, 'seller')
      |    end
      |
      |    def invoice
      |      submodel_at(ReferenceType, 'invoice')
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:customer] = customer.to_h if has? 'customer'
      |      hash[:company] = company.to_h if has? 'company'
      |      hash[:seller] = seller.to_h if has? 'seller'
      |      hash[:invoice] = invoice.to_h if has? 'invoice'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for subtype with extension' do
    expect(scaffolds['parsers/customer.rb']).to eq_multiline(%{
      |module Parsers
      |  class Customer < BaseElement
      |    include ParserCore::BaseParser
      |
      |    def id
      |      at 'id'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:id] = id if has? 'id'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for subtype with extension and choice' do
    expect(scaffolds['parsers/seller.rb']).to eq_multiline(%{
      |module Parsers
      |  class Seller < BaseElement
      |    include ParserCore::BaseParser
      |
      |    def contact_info
      |      submodel_at(ContactInfo, 'contactInfo')
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:contact_info] = contact_info.to_h if has? 'contactInfo'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for type with simpleType extension' do
    expect(scaffolds['parsers/reference_type.rb']).to eq_multiline(%{
      |module Parsers
      |  class ReferenceType
      |    include ParserCore::BaseParser
      |
      |    def id
      |      at 'ID'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:id] = id if has? 'ID'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for subtype from extension' do
    expect(scaffolds['parsers/contact_info.rb']).to eq_multiline(%{
      |module Parsers
      |  class ContactInfo
      |    include ParserCore::BaseParser
      |
      |    def email
      |      at 'email'
      |    end
      |
      |    def phone
      |      at 'phone'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:email] = email if has? 'email'
      |      hash[:phone] = phone if has? 'phone'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for element from which is extended' do
    expect(scaffolds['parsers/base_element.rb']).to eq_multiline(%{
      |module Parsers
      |  class BaseElement
      |    include ParserCore::BaseParser
      |
      |    def title
      |      at 'title'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:title] = title if has? 'title'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  # it 'scaffolds parser for elements with only extension and no other content' do
  #   expect(scaffolds['parsers/person.rb']).to eq_multiline(%{
  #     |module Parsers
  #     |  class Person < BaseElement
  #     |    include ParserCore::BaseParser
  #     |  end
  #     |end })
  # end

  it 'scaffolds parser for company' do
    expect(scaffolds['parsers/company.rb']).to eq_multiline(%{
      |module Parsers
      |  class Company < BaseElement
      |    include ParserCore::BaseParser
      |  end
      |end })
  end

  it 'scaffolds builder for type with various extensions' do
    expect(scaffolds['builders/order.rb']).to eq_multiline(%{
      |module Builders
      |  class Order
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      if data.key? :customer
      |        root << Customer.new('customer', data[:customer]).builder
      |      end
      |      if data.key? :company
      |        root << Company.new('company', data[:company]).builder
      |      end
      |      if data.key? :seller
      |        root << Seller.new('seller', data[:seller]).builder
      |      end
      |      if data.key? :invoice
      |        root << ReferenceType.new('invoice', data[:invoice]).builder
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for subtype with extension' do
    expect(scaffolds['builders/customer.rb']).to eq_multiline(%{
      |module Builders
      |  class Customer < BaseElement
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      super.nodes.each do |n||
      |        root << n
      |      end
      |
      |      root << build_element('id', data[:id]) if data.key? :id
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for subtype with extension and choice' do
    expect(scaffolds['builders/seller.rb']).to eq_multiline(%{
      |module Builders
      |  class Seller < BaseElement
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      super.nodes.each do |n||
      |        root << n
      |      end
      |
      |      if data.key? :contact_info
      |        root << ContactInfo.new('contactInfo', data[:contact_info]).builder
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type with simpleType extension' do
    expect(scaffolds['builders/reference_type.rb']).to eq_multiline(%{
      |module Builders
      |  class ReferenceType
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('ID', data[:id]) if data.key? :id
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for subtype from extension' do
    expect(scaffolds['builders/contact_info.rb']).to eq_multiline(%{
      |module Builders
      |  class ContactInfo
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('email', data[:email]) if data.key? :email
      |      root << build_element('phone', data[:phone]) if data.key? :phone
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for element from which is extended' do
    expect(scaffolds['builders/base_element.rb']).to eq_multiline(%{
      |module Builders
      |  class BaseElement
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('title', data[:title]) if data.key? :title
      |
      |      root
      |    end
      |  end
      |end })
  end
end
