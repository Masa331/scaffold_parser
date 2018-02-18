require 'base_element'
require 'dokl_ref_type'
require 'doklad_hraz'

class UhradaType
  include BaseElement

  def doklad_uhr
    submodel_at(DoklRefType, :DokladUhr)
  end

  def doklad_hraz
    submodel_at(DokladHraz, :DokladHraz)
  end
end
