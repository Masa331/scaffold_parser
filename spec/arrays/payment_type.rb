require 'base_element'
require 'payment'

class PaymentType
  include BaseElement

  def payments_list
    array_of_at(Payment, [:payments_list, :payment])
  end

  def to_h
    { payments_list: payments_list.map(&:to_h)
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
