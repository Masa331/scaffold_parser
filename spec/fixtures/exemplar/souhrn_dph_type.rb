require 'base_element'
require 'dalsi_sazba'

class SouhrnDPHType
  include BaseElement

  def zaklad0
    at :Zaklad0
  end

  def seznam_dalsi_sazby
    array_of_at(DalsiSazba, [:SeznamDalsiSazby, :DalsiSazba])
  end

  def to_h
    { zaklad0: zaklad0,
      seznam_dalsi_sazby: seznam_dalsi_sazby.map(&:to_h)
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
