require 'base_element'
require 'neskl_polozka'

class PolObjednType
  include BaseElement

  def popis
    at :Popis
  end

  def something
    at :something
  end

  def neskl_polozka
    submodel_at(NesklPolozka, :NesklPolozka)
  end

  def to_h
    { popis: popis,
      something: something,
      neskl_polozka: neskl_polozka.to_h
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
