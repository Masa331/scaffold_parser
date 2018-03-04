require 'base_builder'

module Builders
  class Order
    include BaseBuilder

    attr_accessor :name, :company_name

    def builder
      root = Ox::Element.new('order')

      root << Ox::Element.new('name') << name if name
      root << Ox::Element.new('company_name') << company_name if company_name

      root
    end
  end
end
