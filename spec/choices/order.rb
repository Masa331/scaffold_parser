require 'base_element'

class Order
  include BaseElement

  def name
    at :name
  end

  def company_name
    at :company_name
  end

  def to_h
    { name: name,
      company_name: company_name
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
