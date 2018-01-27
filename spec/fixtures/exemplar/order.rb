require 'something/base_element'

module Something
  class Order
    include BaseElement

    def name
      at 'name'
    end
  end
end
