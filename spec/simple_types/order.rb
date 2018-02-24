require 'base_element'

class Order
  include BaseElement

  def name
    at :name
  end

  def title
    at :title
  end

  def total
    at :Total
  end

  def to_h
    { name: name,
      title: title,
      total: total
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
