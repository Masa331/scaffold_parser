RSpec.describe ScaffoldParser do
  it 'extensions are parsed correctly' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    order_parser = codes['parsers/order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'base_parser'
      |require 'customer'
      |require 'seller'
      |require 'reference_type'
      |
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def customer
      |      submodel_at(Customer, :customer)
      |    end
      |
      |    def seller
      |      submodel_at(Seller, :seller)
      |    end
      |
      |    def invoice
      |      submodel_at(ReferenceType, :invoice)
      |    end
      |
      |    def to_h
      |      { customer: customer.to_h,
      |        seller: seller.to_h,
      |        invoice: invoice.to_h
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    customer_parser = codes['parsers/customer.rb']
    expect(customer_parser).to eq_multiline(%{
      |require 'base_parser'
      |
      |module Parsers
      |  class Customer
      |    include BaseParser
      |
      |    def id
      |      at :id
      |    end
      |
      |    def title
      |      at :title
      |    end
      |
      |    def to_h
      |      { id: id,
      |        title: title
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    seller_parser = codes['parsers/seller.rb']
    expect(seller_parser).to eq_multiline(%{
      |require 'base_parser'
      |require 'contact_info'
      |
      |module Parsers
      |  class Seller
      |    include BaseParser
      |
      |    def title
      |      at :title
      |    end
      |
      |    def contact_info
      |      submodel_at(ContactInfo, :contactInfo)
      |    end
      |
      |    def to_h
      |      { title: title,
      |        contact_info: contact_info.to_h
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    reference_type_parser = codes['parsers/reference_type.rb']
    expect(reference_type_parser).to eq_multiline(%{
      |require 'base_parser'
      |
      |module Parsers
      |  class ReferenceType
      |    include BaseParser
      |
      |    def id
      |      at :ID
      |    end
      |
      |    def to_h
      |      { id: id
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    contact_info_parser = codes['parsers/contact_info.rb']
    expect(contact_info_parser).to eq_multiline(%{
      |require 'base_parser'
      |
      |module Parsers
      |  class ContactInfo
      |    include BaseParser
      |
      |    def email
      |      at :email
      |    end
      |
      |    def phone
      |      at :phone
      |    end
      |
      |    def to_h
      |      { email: email,
      |        phone: phone
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    order_builder = codes['builders/order.rb']
    expect(order_builder).to eq_multiline(%{
      |require 'base_builder'
      |require 'customer'
      |require 'seller'
      |require 'reference_type'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    attr_accessor :customer, :seller, :invoice
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << Customer.new(customer, 'customer').builder if customer
      |      root << Seller.new(seller, 'seller').builder if seller
      |      root << ReferenceType.new(invoice, 'invoice').builder if invoice
      |
      |      root
      |    end
      |  end
      |end })

    customer_builder = codes['builders/customer.rb']
    expect(customer_builder).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class Customer
      |    include BaseBuilder
      |
      |    attr_accessor :id, :title
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << (Ox::Element.new('id') << id) if id
      |      root << (Ox::Element.new('title') << title) if title
      |
      |      root
      |    end
      |  end
      |end })

    seller_builder = codes['builders/seller.rb']
    expect(seller_builder).to eq_multiline(%{
      |require 'base_builder'
      |require 'contact_info'
      |
      |module Builders
      |  class Seller
      |    include BaseBuilder
      |
      |    attr_accessor :title, :contact_info
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << (Ox::Element.new('title') << title) if title
      |      root << ContactInfo.new(contact_info, 'contactInfo').builder if contact_info
      |
      |      root
      |    end
      |  end
      |end })

    contact_info_builder = codes['builders/contact_info.rb']
    expect(contact_info_builder).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class ContactInfo
      |    include BaseBuilder
      |
      |    attr_accessor :email, :phone
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << (Ox::Element.new('email') << email) if email
      |      root << (Ox::Element.new('phone') << phone) if phone
      |
      |      root
      |    end
      |  end
      |end })

    reference_type_builder = codes['builders/reference_type.rb']
    expect(reference_type_builder).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class ReferenceType
      |    include BaseBuilder
      |
      |    attr_accessor :id
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << (Ox::Element.new('ID') << id) if id
      |
      |      root
      |    end
      |  end
      |end })
  end
end
