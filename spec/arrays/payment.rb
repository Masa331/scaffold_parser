require 'base_element'

class Payment
  include BaseElement

  def amount
    at :amount
  end

  def to_h
    { amount: amount
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
