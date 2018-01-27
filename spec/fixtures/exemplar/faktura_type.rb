require 'base_element'
require 'valuty'

class FakturaType
  include BaseElement

  def doklad
    at 'Doklad'
  end

  def ev_cis_dokl
    at 'EvCisDokl'
  end

  def zpusob_uctovani
    at 'ZpusobUctovani'
  end

  def popis
    at 'Popis'
  end

  def popis2
    at 'Popis2'
  end

  def valuty
    element_xml = at 'Valuty'

    Valuty.new(element_xml) if element_xml
  end
end
