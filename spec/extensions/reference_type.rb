require 'base_element'

class ReferenceType
  include BaseElement

  def id
    at :ID
  end

  def to_h
    { id: id
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
