RSpec.describe ScaffoldParser do
  it 'extensions are parsed correctly' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    order_parser = codes['parsers/order.rb']
    expect(order_parser).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def customer
      |      submodel_at(Customer, 'customer')
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
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:customer] = customer.to_h_with_attrs if has? 'customer'
      |      hash[:seller] = seller.to_h_with_attrs if has? 'seller'
      |      hash[:invoice] = invoice.to_h_with_attrs if has? 'invoice'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'extensions are parsed correctly' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    customer_parser = codes['parsers/customer.rb']
    expect(customer_parser).to eq_multiline(%{
      |module Parsers
      |  class Customer < BaseElement
      |    include BaseParser
      |
      |    def id
      |      at 'id'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:id] = id if has? 'id'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      |end })
  end

  it 'extensions are parsed correctly' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    seller_parser = codes['parsers/seller.rb']
    expect(seller_parser).to eq_multiline(%{
      |module Parsers
      |  class Seller < BaseElement
      |    include BaseParser
      |
      |    def contact_info
      |      submodel_at(ContactInfo, 'contactInfo')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:contact_info] = contact_info.to_h_with_attrs if has? 'contactInfo'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      |end })
  end

  it 'extensions are parsed correctly' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    reference_type_parser = codes['parsers/reference_type.rb']
    expect(reference_type_parser).to eq_multiline(%{
      |module Parsers
      |  class ReferenceType
      |    include BaseParser
      |
      |    def id
      |      at 'ID'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:id] = id if has? 'ID'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'extensions are parsed correctly' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    contact_info_parser = codes['parsers/contact_info.rb']
    expect(contact_info_parser).to eq_multiline(%{
      |module Parsers
      |  class ContactInfo
      |    include BaseParser
      |
      |    def email
      |      at 'email'
      |    end
      |
      |    def phone
      |      at 'phone'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:email] = email if has? 'email'
      |      hash[:phone] = phone if has? 'phone'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  xit 'builder scaffolder output matches template' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    order_builder = codes['builders/order.rb']
    expect(order_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |require 'builders/customer'
      |require 'builders/seller'
      |require 'builders/reference_type'
      |
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
      |      if data.key? :customer
      |        root << Customer.new('customer', data[:customer]).builder
      |      end
      |
      |      if data.key? :seller
      |        root << Seller.new('seller', data[:seller]).builder
      |      end
      |
      |      if data.key? :invoice
      |        root << ReferenceType.new('invoice', data[:invoice]).builder
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    customer_builder = codes['builders/customer.rb']
    expect(customer_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class Customer
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('id', data[:id]) if data.key? :id
      |      root << build_element('title', data[:title]) if data.key? :title
      |
      |      root
      |    end
      |  end
      |end })

    seller_builder = codes['builders/seller.rb']
    expect(seller_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |require 'builders/contact_info'
      |
      |module Builders
      |  class Seller
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('title', data[:title]) if data.key? :title
      |
      |      if data.key? :contact_info
      |        root << ContactInfo.new('contactInfo', data[:contact_info]).builder
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    contact_info_builder = codes['builders/contact_info.rb']
    expect(contact_info_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class ContactInfo
      |    include BaseBuilder
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

    reference_type_builder = codes['builders/reference_type.rb']
    expect(reference_type_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class ReferenceType
      |    include BaseBuilder
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
end
