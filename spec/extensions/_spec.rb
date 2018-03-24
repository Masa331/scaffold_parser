RSpec.describe ScaffoldParser do
  it 'extensions are parsed correctly' do
    codes = scaffold_schema('./spec/extensions/schema.xsd')

    order_parser = codes['parsers/order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |require 'parsers/customer'
      |require 'parsers/seller'
      |require 'parsers/reference_type'
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
      |      hash = {}
      |
      |      hash[:customer] = customer.to_h if raw.key? :customer
      |      hash[:seller] = seller.to_h if raw.key? :seller
      |      hash[:invoice] = invoice.to_h if raw.key? :invoice
      |
      |      hash
      |    end
      |  end
      |end })

    customer_parser = codes['parsers/customer.rb']
    expect(customer_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
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
      |      hash = {}
      |
      |      hash[:id] = id if raw.key? :id
      |      hash[:title] = title if raw.key? :title
      |
      |      hash
      |    end
      |  end
      |end })

    seller_parser = codes['parsers/seller.rb']
    expect(seller_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |require 'parsers/contact_info'
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
      |      hash = {}
      |
      |      hash[:title] = title if raw.key? :title
      |      hash[:contact_info] = contact_info.to_h if raw.key? :contactInfo
      |
      |      hash
      |    end
      |  end
      |end })

    reference_type_parser = codes['parsers/reference_type.rb']
    expect(reference_type_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
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
      |      hash = {}
      |
      |      hash[:id] = id if raw.key? :ID
      |
      |      hash
      |    end
      |  end
      |end })

    contact_info_parser = codes['parsers/contact_info.rb']
    expect(contact_info_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
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
      |      hash = {}
      |
      |      hash[:email] = email if raw.key? :email
      |      hash[:phone] = phone if raw.key? :phone
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :customer
      |        root << Customer.new(attributes[:customer], 'customer').builder
      |      end
      |
      |      if attributes.key? :seller
      |        root << Seller.new(attributes[:seller], 'seller').builder
      |      end
      |
      |      if attributes.key? :invoice
      |        root << ReferenceType.new(attributes[:invoice], 'invoice').builder
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :id
      |        element = Ox::Element.new('id')
      |        element << attributes[:id] if attributes[:id]
      |        root << element
      |      end
      |
      |      if attributes.key? :title
      |        element = Ox::Element.new('title')
      |        element << attributes[:title] if attributes[:title]
      |        root << element
      |      end
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :title
      |        element = Ox::Element.new('title')
      |        element << attributes[:title] if attributes[:title]
      |        root << element
      |      end
      |
      |      if attributes.key? :contact_info
      |        root << ContactInfo.new(attributes[:contact_info], 'contactInfo').builder
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :email
      |        element = Ox::Element.new('email')
      |        element << attributes[:email] if attributes[:email]
      |        root << element
      |      end
      |
      |      if attributes.key? :phone
      |        element = Ox::Element.new('phone')
      |        element << attributes[:phone] if attributes[:phone]
      |        root << element
      |      end
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :id
      |        element = Ox::Element.new('ID')
      |        element << attributes[:id] if attributes[:id]
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end
end
