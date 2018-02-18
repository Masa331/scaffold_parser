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
end
