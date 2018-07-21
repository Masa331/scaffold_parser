RSpec.describe 'arrays' do
  it 'schema with namespaces' do
    schema = <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

        <xs:complexType name="orderType">
          <xs:sequence>
            <xs:element name="links" type="linksType"/>
          </xs:sequence>
        </xs:complexType>

        <xs:complexType name="linksType">
          <xs:sequence>
            <xs:element name="link" type="linkElemetType" maxOccurs="unbounded"/>
          </xs:sequence>
        </xs:complexType>
      </xs:schema>
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order_type.rb']
    expect(scaffold).to eq(
      |module Parsers
      |  class OrderType
      |    include ParserCore::BaseParser
      |
      |    def links
      |      array_of_at(LinkElemetType, ['links', 'link'])
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:links] = links.map(&:to_h) if has? 'links'
      |
      |      hash
      |    end
      |  end
      end
  end

  it 'schema with namespaces' do
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
            <xs:element name="item" type="item:itemType" maxOccurs="unbounded"/>
            <xs:element name="note" maxOccurs="unbounded"/>
            <xs:element name="emails">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="address" maxOccurs="unbounded"/>
                </xs:sequence>
              </xs:complexType>
            </xs:element>
            <xs:element name="payments">
              <xs:complexType>
                <xs:sequence>
                  <xs:element name="payment" type="pay:paymentType" maxOccurs="unbounded"/>
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
      |module Parsers
      |  module Inv
      |    class OrderType
      |      include ParserCore::BaseParser
      |
      |      def item
      |        array_of_at(Item::ItemType, ['inv:item'])
      |      end
      |
      |      def note
      |        array_of_at(String, ['inv:note'])
      |      end
      |
      |      def emails
      |        array_of_at(String, ['inv:emails', 'inv:address'])
      |      end
      |
      |      def payments
      |        array_of_at(Pay::PaymentType, ['inv:payments', 'inv:payment'])
      |      end
      |
      |      def to_h
      |        hash[:attributes] = attributes
      |
      |        hash[:item] = item.map(&:to_h) if has? 'inv:item'
      |        hash[:note] = note if has? 'inv:note'
      |        hash[:emails] = emails if has? 'inv:emails'
      |        hash[:payments] = payments.map(&:to_h) if has? 'inv:payments'
      |
      |        hash
      |      end
      |    end
      |  end
      end
  end

  it 'fixed max occurs' do
    schema =
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="souhrnDPHType">
      |    <xs:sequence>
      |      <xs:element name="Zaklad0" type="xs:string">
      |      </xs:element>
      |      <xs:element name="SeznamDalsiSazby">
      |        <xs:complexType>
      |          <xs:sequence>
      |            <xs:element name="DalsiSazba" maxOccurs="6">
      |              <xs:complexType>
      |                <xs:sequence>
      |                  <xs:element name="Popis">
      |                  </xs:element>
      |                  <xs:element name="Sazba">
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
    scaffold = Hash[scaffolds]['parsers/souhrn_dph_type.rb']
    expect(scaffold).to eq(
      |module Parsers
      |  class SouhrnDPHType
      |    include ParserCore::BaseParser
      |
      |    def zaklad0
      |      at 'Zaklad0'
      |    end
      |
      |    def seznam_dalsi_sazby
      |      array_of_at(DalsiSazba, ['SeznamDalsiSazby', 'DalsiSazba'])
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:zaklad0] = zaklad0 if has? 'Zaklad0'
      |      hash[:seznam_dalsi_sazby] = seznam_dalsi_sazby.map(&:to_h) if has? 'SeznamDalsiSazby'
      |
      |      hash
      |    end
      |  end
      end
  end

  it 'unbounded element with extension wrapped in extension...' do
    schema =
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:element name="MoneyData">
      |    <xs:complexType>
      |      <xs:sequence>
      |        <xs:element name="SeznamFaktVyd" minOccurs="0">
      |          <xs:complexType>
      |            <xs:complexContent>
      |              <xs:extension base="seznamType">
      |                <xs:sequence>
      |                  <xs:element name="FaktVyd" minOccurs="0" maxOccurs="unbounded">
      |                    <xs:complexType>
      |                      <xs:complexContent>
      |                        <xs:extension base="fakturaType"/>
      |                      </xs:complexContent>
      |                    </xs:complexType>
      |                  </xs:element>
      |                </xs:sequence>
      |              </xs:extension>
      |            </xs:complexContent>
      |          </xs:complexType>
      |        </xs:element>
      |      </xs:sequence>
      |    </xs:complexType>
      |  </xs:element>
      |
      |  <xs:complexType name="seznamType">
      |    <xs:sequence>
      |      <xs:element name="title" type"xs:string"/>
      |    </xs:sequence>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/money_data.rb']
    expect(scaffold).to eq(
      |module Parsers
      |  class MoneyData
      |    include ParserCore::BaseParser
      |
      |    def seznam_fakt_vyd
      |      submodel_at(SeznamFaktVyd, 'SeznamFaktVyd')
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:seznam_fakt_vyd] = seznam_fakt_vyd.to_h if has? 'SeznamFaktVyd'
      |
      |      hash
      |    end
      |  end
      end

    scaffold = Hash[scaffolds]['parsers/seznam_fakt_vyd.rb']
    expect(scaffold).to eq(
      |module Parsers
      |  class SeznamFaktVyd < SeznamType
      |    include ParserCore::BaseParser
      |
      |    def fakt_vyd
      |      array_of_at(FaktVyd, ['FaktVyd'])
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:fakt_vyd] = fakt_vyd.map(&:to_h) if has? 'FaktVyd'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      end
  end

  let(:scaffolds) { scaffold_schema('./spec/arrays/schema.xsd') }

  it 'scaffolds parser for type with various elements which can occure more than once' do
    expect(scaffolds['parsers/order.rb']).to eq(
      |module Parsers
      |  class Order
      |    include ParserCore::BaseParser
      |
      |    def items
      |      array_of_at(ItemType, ['items', 'Item'])
      |    end
      |
      |    def payments
      |      submodel_at(PaymentType, 'payments')
      |    end
      |
      |    def documents
      |      array_of_at(String, ['documents', 'document'])
      |    end
      |
      |    def messages
      |      submodel_at(Messages, 'messages')
      |    end
      |
      |    def id
      |      array_of_at(String, ['ID'])
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:items] = items.map(&:to_h) if has? 'items'
      |      hash[:payments] = payments.to_h if has? 'payments'
      |      hash[:documents] = documents if has? 'documents'
      |      hash[:messages] = messages.to_h if has? 'messages'
      |      hash[:id] = id if has? 'ID'
      |
      |      hash
      |    end
      |  end
      end
  end

  it 'scaffolds parser for type including element which can occure more than once' do
    expect(scaffolds['parsers/payment_type.rb']).to eq(
      |module Parsers
      |  class PaymentType
      |    include ParserCore::BaseParser
      |
      |    def payments_list
      |      array_of_at(Payment, ['payments_list', 'payment'])
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:payments_list] = payments_list.map(&:to_h) if has? 'payments_list'
      |
      |      hash
      |    end
      |  end
      end
  end

  it 'scaffolds parser for subtype which can occure more than once' do
    expect(scaffolds['parsers/payment.rb']).to eq(
      |module Parsers
      |  class Payment
      |    include ParserCore::BaseParser
      |
      |    def amount
      |      at 'amount'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:amount] = amount if has? 'amount'
      |
      |      hash
      |    end
      |  end
      end
  end

  it 'scaffolds parser for subtype with extension and element which can occure more than once' do
    expect(scaffolds['parsers/messages.rb']).to eq(
      |module Parsers
      |  class Messages < MessageType
      |    include ParserCore::BaseParser
      |
      |    def recipient
      |      array_of_at(RecipientType, ['recipient'])
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:recipient] = recipient.map(&:to_h) if has? 'recipient'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      end
  end

  it 'scaffolds parser for subtype in extension which can occure more than once' do
    expect(scaffolds['parsers/recipient_type.rb']).to eq(
      |module Parsers
      |  class RecipientType
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
      end
  end

  it 'scaffolds parser subtype which is inherited with element which can occure more than once' do
    expect(scaffolds['parsers/message_type.rb']).to eq(
      |module Parsers
      |  class MessageType
      |    include ParserCore::BaseParser
      |
      |    def error
      |      array_of_at(String, ['error'])
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:error] = error if has? 'error'
      |
      |      hash
      |    end
      |  end
      end
  end

  it 'scaffolds builder for type with various elements which can occure more than once' do
    expect(scaffolds['builders/order.rb']).to eq(
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
      |      if data.key? :items
      |        element = Ox::Element.new('items')
      |        data[:items].each { |i| element << ItemType.new('Item', i).builder }
      |        root << element
      |      end
      |      if data.key? :payments
      |        root << PaymentType.new('payments', data[:payments]).builder
      |      end
      |      if data.key? :documents
      |        element = Ox::Element.new('documents')
      |        data[:documents].map { |i| Ox::Element.new('document') << i }.each { |i| element << i }
      |        root << element
      |      end
      |      if data.key? :messages
      |        root << Messages.new('messages', data[:messages]).builder
      |      end
      |      if data.key? :id
      |        data[:id].map { |i| Ox::Element.new('ID') << i }.each { |i| root << i }
      |      end
      |
      |      root
      |    end
      |  end
      end
  end

  it 'scaffolds builder for type including element which can occure more than once' do
    expect(scaffolds['builders/payment_type.rb']).to eq(
      |module Builders
      |  class PaymentType
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      if data.key? :payments_list
      |        element = Ox::Element.new('payments_list')
      |        data[:payments_list].each { |i| element << Payment.new('payment', i).builder }
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      end
  end

  it 'scaffolds builder for subtype which can occure more than once' do
    payment_parser = scaffolds['builders/payment.rb']
    expect(payment_parser).to eq(
      |module Builders
      |  class Payment
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('amount', data[:amount]) if data.key? :amount
      |
      |      root
      |    end
      |  end
      end
  end

  it 'scaffolds builder for subtype with extension and element which can occure more than once' do
    expect(scaffolds['builders/messages.rb']).to eq(
      |module Builders
      |  class Messages < MessageType
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
      |      if data.key? :recipient
      |        data[:recipient].each { |i| root << RecipientType.new('recipient', i).builder }
      |      end
      |
      |      root
      |    end
      |  end
      end
  end

  it 'scaffolds builder for subtype in extension which can occure more than once' do
    expect(scaffolds['builders/recipient_type.rb']).to eq(
      |module Builders
      |  class RecipientType
      |    include ParserCore::BaseBuilder
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
      end
  end

  it 'scaffolds builder for subtype which is inherited with element which can occure more than once' do
    expect(scaffolds['builders/message_type.rb']).to eq(
      |module Builders
      |  class MessageType
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      if data.key? :error
      |        data[:error].map { |i| Ox::Element.new('error') << i }.each { |i| root << i }
      |      end
      |
      |      root
      |    end
      |  end
      end
  end
end
