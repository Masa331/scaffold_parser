require 'base_element'

class Customer
  include BaseElement

  def id
    at :id
  end

  def title
    at :title
  end

  def to_h
    { id: id,
      title: title
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
