require 'base_element'
require 'customer'
require 'seller'
require 'reference_type'

class Order
  include BaseElement

  def customer
    submodel_at(Customer, :customer)
  end

  def seller
    submodel_at(Seller, :seller)
  end

  def invoice
    submodel_at(ReferenceType, :invoice)
  end

  def to_h
    { customer: customer.to_h,
      seller: seller.to_h,
      invoice: invoice.to_h
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
