require 'base_element'

class MenaType
  include BaseElement

  def kod
    at :Kod
  end

  def mnozstvi
    at :Mnozstvi
  end

  def kurs
    at :Kurs
  end
end
