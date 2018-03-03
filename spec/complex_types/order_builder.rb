require 'base_builder'
require 'currency'
require 'customer_type'

module Builders
  class Order
    include BaseBuilder

    attr_accessor :currency, :customer, :customer2

    def builder
      root = Ox::Element.new('order')

      root << Currency.new(currency).builder if currency
      root << CustomerType.new(customer).builder if customer
      root << CustomerType.new(customer2).builder if customer2

      root
    end
  end
end
