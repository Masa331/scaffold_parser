RSpec.describe 'simple types' do
  it 'parser scaffolder output matches template' do
    parser_code = parser_for('./spec/simple_types/schema.xsd', 'order.rb')

    expect(parser_code).to eq_multiline(%{
      |require 'base_element'
      |
      |class Order
      |  include BaseElement
      |
      |  def name
      |    at :name
      |  end
      |
      |  def title
      |    at :title
      |  end
      |
      |  def total
      |    at :Total
      |  end
      |
      |  def to_h
      |    { name: name,
      |      title: title,
      |      total: total
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
    builder_code = builder_for('./spec/simple_types/schema.xsd', 'builders/order.rb')

    expect(builder_code).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    attr_accessor :name, :title, :total
      |
      |    def builder
      |      root = Ox::Element.new('order')
      |
      |      root << Ox::Element.new('name') << name if name
      |      root << Ox::Element.new('title') << title if title
      |      root << Ox::Element.new('Total') << total if total
      |
      |      root
      |    end
      |  end
      |end })
  end
end
