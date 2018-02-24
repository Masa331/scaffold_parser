require 'base_element'

class ContactInfo
  include BaseElement

  def email
    at :email
  end

  def phone
    at :phone
  end

  def to_h
    { email: email,
      phone: phone
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
