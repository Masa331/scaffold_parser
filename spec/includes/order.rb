require 'base_element'

class Order
  include BaseElement

  def title
    at :title
  end

  def title2
    at :title2
  end

  def to_h
    { title: title,
      title2: title2
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
