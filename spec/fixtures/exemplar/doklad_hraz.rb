require 'base_element'
require 'eet_type'

class DokladHraz
  include BaseElement

  def id_dokladu
    at :IDDokladu
  end

  def eet
    submodel_at(EETType, :EET)
  end
end