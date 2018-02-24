require 'base_element'
require 'contact_info'

class Seller
  include BaseElement

  def title
    at :title
  end

  def contact_info
    submodel_at(ContactInfo, :contactInfo)
  end

  def to_h
    { title: title,
      contact_info: contact_info.to_h
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
