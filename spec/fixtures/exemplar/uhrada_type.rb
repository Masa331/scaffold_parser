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

  def to_h
    { doklad_uhr: doklad_uhr.to_h,
      doklad_hraz: doklad_hraz.to_h
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
