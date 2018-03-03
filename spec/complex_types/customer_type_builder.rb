require 'base_builder'

module Builders
  class CustomerType
    include BaseBuilder

    attr_accessor :name

    def builder
      root = Ox::Element.new('customerType')

      root << Ox::Element.new('name') << name if name

      root
    end
  end
end
