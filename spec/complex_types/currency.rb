require 'base_element'

class Currency
  include BaseElement

  def currency_id
    at :currencyId
  end

  def to_h
    { currency_id: currency_id
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
