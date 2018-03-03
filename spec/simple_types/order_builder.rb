require 'base_builder'

module Builders
  class Order
    include BaseBuilder

    attr_accessor :name, :title, :total

    def builder
      root = Ox::Element.new('order')

      root << Ox::Element.new('name') << name if name
      root << Ox::Element.new('title') << title if title
      root << Ox::Element.new('Total') << total if total

      root
    end
  end
end
