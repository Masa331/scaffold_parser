require 'base_element'
require 'currency'
require 'customer_type'

class Order
  include BaseElement

  def currency
    submodel_at(Currency, :currency)
  end

  def customer
    submodel_at(CustomerType, :customer)
  end

  def customer2
    submodel_at(CustomerType, :customer2)
  end

  def to_h
    { currency: currency.to_h,
      customer: customer.to_h,
      customer2: customer2.to_h
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
