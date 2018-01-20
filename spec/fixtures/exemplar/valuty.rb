class Valuty
  def mena
    element_xml = at 'Mena'

    MenaType.new(element_xml) if element_xml
  end

  def souhrn_dph
    element_xml = at 'SouhrnDPH'

    SouhrnDphType.new(element_xml) if element_xml
  end

  def celkem
    at 'Celkem'
  end
end
