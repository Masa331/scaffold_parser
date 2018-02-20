require 'base_element'

class DalsiSazba
  include BaseElement

  def popis
    at :Popis
  end

  def to_h
    { popis: popis
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
