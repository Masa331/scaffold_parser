require 'base_element'
require 'valuty'
require 'souhrn_dph_type'
require 'pol_faktury_type'
require 'pol_objedn_type'
require 'uhrada_type'

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

  def celkem
    at :Celkem
  end

  def valuty
    submodel_at(Valuty, :Valuty)
  end

  def souhrn_dph
    submodel_at(SouhrnDPHType, :SouhrnDPH)
  end

  def seznam_polozek
    array_of_at(PolFakturyType, [:SeznamPolozek, :Polozka])
  end

  def seznam_zal_polozek
    array_of_at(PolObjednType, [:SeznamZalPolozek, :Polozka])
  end

  def seznam_uhrad
    array_of_at(UhradaType, [:SeznamUhrad, :Uhrada])
  end

  def dokumenty
    array_of_at(String, [:Dokumenty, :Dokument])
  end
end
