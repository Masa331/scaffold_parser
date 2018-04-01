RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./spec/extensions/schema.xsd') }

  it 'scaffolds parser for type with various extensions' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
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

  it 'scaffolds parser for subtype with extension' do
    expect(scaffolds['parsers/customer.rb']).to eq_multiline(%{
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

  it 'scaffolds parser for subtype with extension and choice' do
    expect(scaffolds['parsers/seller.rb']).to eq_multiline(%{
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

  it 'scaffolds parser for type with simpleType extension' do
    expect(scaffolds['parsers/reference_type.rb']).to eq_multiline(%{
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

  it 'scaffolds parser for subtype from extension' do
    expect(scaffolds['parsers/contact_info.rb']).to eq_multiline(%{
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

  it 'scaffolds parser for element from which is extended' do
    expect(scaffolds['parsers/base_element.rb']).to eq_multiline(%{
      |module Parsers
      |  class BaseElement
      |    include BaseParser
      |
      |    def title
      |      at 'title'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:title] = title if has? 'title'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type with various extensions' do
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
      |      if data.key? :customer
      |        root << Customer.new('customer', data[:customer]).builder
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
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
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
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
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

  it 'scaffolds builder for subtype from extension' do
    expect(scaffolds['builders/contact_info.rb']).to eq_multiline(%{
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
  end

  it 'scaffolds builder for element from which is extended' do
    expect(scaffolds['builders/base_element.rb']).to eq_multiline(%{
      |module Builders
      |  class BaseElement
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
      |      root
      |    end
      |  end
      |end })
  end
end
