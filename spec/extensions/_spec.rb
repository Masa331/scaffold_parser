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
      |class Order
      |  include BaseParser
      |
      |  def customer
      |    submodel_at(Customer, :customer)
      |  end
      |
      |  def seller
      |    submodel_at(Seller, :seller)
      |  end
      |
      |  def invoice
      |    submodel_at(ReferenceType, :invoice)
      |  end
      |
      |  def to_h
      |    { customer: customer.to_h,
      |      seller: seller.to_h,
      |      invoice: invoice.to_h
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    customer_parser = codes['parsers/customer.rb']
    expect(customer_parser).to eq_multiline(%{
      |require 'base_parser'
      |
      |class Customer
      |  include BaseParser
      |
      |  def id
      |    at :id
      |  end
      |
      |  def title
      |    at :title
      |  end
      |
      |  def to_h
      |    { id: id,
      |      title: title
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    seller_parser = codes['parsers/seller.rb']
    expect(seller_parser).to eq_multiline(%{
      |require 'base_parser'
      |require 'contact_info'
      |
      |class Seller
      |  include BaseParser
      |
      |  def title
      |    at :title
      |  end
      |
      |  def contact_info
      |    submodel_at(ContactInfo, :contactInfo)
      |  end
      |
      |  def to_h
      |    { title: title,
      |      contact_info: contact_info.to_h
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    reference_type_parser = codes['parsers/reference_type.rb']
    expect(reference_type_parser).to eq_multiline(%{
      |require 'base_parser'
      |
      |class ReferenceType
      |  include BaseParser
      |
      |  def id
      |    at :ID
      |  end
      |
      |  def to_h
      |    { id: id
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    contact_info_parser = codes['parsers/contact_info.rb']
    expect(contact_info_parser).to eq_multiline(%{
      |require 'base_parser'
      |
      |class ContactInfo
      |  include BaseParser
      |
      |  def email
      |    at :email
      |  end
      |
      |  def phone
      |    at :phone
      |  end
      |
      |  def to_h
      |    { email: email,
      |      phone: phone
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })
  end
end
