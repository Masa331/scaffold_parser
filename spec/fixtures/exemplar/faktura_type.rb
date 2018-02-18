require 'base_element'
require 'valuty'
require 'pol_faktury_type'

class FakturaType
  include BaseElement

  def doklad
    at :Doklad
  end

  def ev_cis_dokl
    at :EvCisDokl
  end

  def zpusob_uctovani
    at :ZpusobUctovani
  end

  def popis
    at :Popis
  end

  def popis2
    at :Popis2
  end

  def valuty
    element_xml = at :Valuty

    Valuty.new(element_xml) if element_xml
  end

  def seznam_polozek
    elements = raw.dig(:SeznamPolozek, :Polozka) || []
    if elements.is_a? Hash
      elements = [elements]
    end

    elements.map do |raw|
      PolFakturyType.new(raw)
    end
  end
end
