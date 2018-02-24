require 'base_element'

class RecipientType
  include BaseElement

  def name
    at :name
  end

  def to_h
    { name: name
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
