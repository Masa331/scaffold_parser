RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./order.xsd', namespace: 'Something') }

  it 'scaffolds parser with given namespace' do
    expect(scaffolds['parsers/order.rb']).to eq(
      |module Something
      |  module Parsers
      |    class Order
      |      include ParserCore::BaseParser
      |
      |      def name
      |        at 'name'
      |      end
      |
      |      def customer
      |        submodel_at(CustomerType, 'customer')
      |      end
      |
      |      def to_h
      |        hash[:attributes] = attributes
      |
      |        hash[:name] = name if has? 'name'
      |        hash[:customer] = customer.to_h if has? 'customer'
      |
      |        hash
      |      end
      |    end
      |  end
      end
  end

  it 'scaffolds builder with given namespace' do
    expect(scaffolds['builders/order.rb']).to eq(
      |module Something
      |  module Builders
      |    class Order
      |      include ParserCore::BaseBuilder
      |
      |      def builder
      |        root = Ox::Element.new(name)
      |        if data.respond_to? :attributes
      |          data.attributes.each { |k, v| root[k] = v }
      |        end
      |
      |        root << build_element('name', data[:name]) if data.key? :name
      |        if data.key? :customer
      |          root << CustomerType.new('customer', data[:customer]).builder
      |        end
      |
      |        root
      |      end
      |    end
      |  end
      end
  end

  it 'scaffolds parser for schema with namespaced elements' do
    schema =
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema
      |  xmlns:xs="http://www.w3.org/2001/XMLSchema"
      |  xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
      |  xmlns="http://www.stormware.cz/schema/version_2/invoice.xsd"
      |  targetNamespace="http://www.stormware.cz/schema/version_2/invoice.xsd"
      |  elementFormDefault="qualified">
      |  <xs:element name="order" type="orderType"/>
      |
      |  <xs:complexType name="orderType">
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

    scaffold = Hash[scaffolds]['parsers/inv/order_type.rb']
    expect(scaffold).to eq(
      |module Parsers
      |  module Inv
      |    class OrderType
      |      include ParserCore::BaseParser
      |
      |      def name
      |        at 'inv:name'
      |      end
      |
      |      def company_name
      |        at 'inv:company_name'
      |      end
      |
      |      def company_address
      |        at 'inv:company_address'
      |      end
      |
      |      def to_h
      |        hash[:attributes] = attributes
      |
      |        hash[:name] = name if has? 'inv:name'
      |        hash[:company_name] = company_name if has? 'inv:company_name'
      |        hash[:company_address] = company_address if has? 'inv:company_address'
      |
      |        hash
      |      end
      |    end
      |  end
      end

    scaffold = Hash[scaffolds]['builders/inv/order_type.rb']
    expect(scaffold).to eq(
      |module Builders
      |  module Inv
      |    class OrderType
      |      include ParserCore::BaseBuilder
      |
      |      def builder
      |        root = Ox::Element.new(name)
      |        if data.respond_to? :attributes
      |          data.attributes.each { |k, v| root[k] = v }
      |        end
      |
      |        root << build_element('inv:name', data[:name]) if data.key? :name
      |        root << build_element('inv:company_name', data[:company_name]) if data.key? :company_name
      |        root << build_element('inv:company_address', data[:company_address]) if data.key? :company_address
      |
      |        root
      |      end
      |    end
      |  end
      end
  end
end
