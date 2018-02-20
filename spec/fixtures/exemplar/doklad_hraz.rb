require 'base_element'
require 'eet_type'

class DokladHraz
  include BaseElement

  def id_dokladu
    at :IDDokladu
  end

  def eet
    submodel_at(EETType, :EET)
  end

  def to_h
    { id_dokladu: id_dokladu,
      eet: eet.to_h
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
