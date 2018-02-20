require 'something/base_element'

module Something
  class Order
    include BaseElement

    def name
      at :name
    end

    def to_h
      { name: name
      }.delete_if { |k, v| v.nil? || v.empty? }
    end
  end
end
