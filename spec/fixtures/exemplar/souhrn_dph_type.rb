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
end
