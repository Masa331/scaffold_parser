require 'base_builder'

module Builders
  class Currency
    include BaseBuilder

    attr_accessor :currency_id

    def builder
      root = Ox::Element.new('currency')

      root << Ox::Element.new('currencyId') << currency_id if currency_id

      root
    end
  end
end
