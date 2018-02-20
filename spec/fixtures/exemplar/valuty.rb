require 'base_element'
require 'mena_type'
require 'souhrn_dph_type'

class Valuty
  include BaseElement

  def celkem
    at :Celkem
  end

  def mena
    submodel_at(MenaType, :Mena)
  end

  def souhrn_dph
    submodel_at(SouhrnDPHType, :SouhrnDPH)
  end

  def to_h
    { celkem: celkem,
      mena: mena.to_h,
      souhrn_dph: souhrn_dph.to_h
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
