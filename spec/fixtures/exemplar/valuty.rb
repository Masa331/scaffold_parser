require 'mena_type'
require 'souhrn_dph_type'

class Valuty
  def celkem
    at 'Celkem'
  end

  def mena
    element_xml = at 'Mena'

    MenaType.new(element_xml) if element_xml
  end

  def souhrn_dph
    element_xml = at 'SouhrnDPH'

    SouhrnDphType.new(element_xml) if element_xml
  end
end
