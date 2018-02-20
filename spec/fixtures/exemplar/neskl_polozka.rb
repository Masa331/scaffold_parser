require 'base_element'

class NesklPolozka
  include BaseElement

  def zkrat
    at :Zkrat
  end

  def to_h
    { zkrat: zkrat
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
