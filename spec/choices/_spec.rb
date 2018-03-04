RSpec.describe 'choices' do
  it 'parser scaffolder matches template' do
    parser_code = parser_for('./spec/choices/schema.xsd', './tmp/order.rb')

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
       |  def company_name
       |    at :company_name
       |  end
       |
       |  def to_h
       |    { name: name,
       |      company_name: company_name
       |    }.delete_if { |k, v| v.nil? || v.empty? }
       |  end
       |end })
  end

  it 'builder scaffolder matches template' do
    builder_code = builder_for('./spec/choices/schema.xsd', './tmp/builders/order.rb')

    expect(builder_code).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    attr_accessor :name, :company_name
      |
      |    def builder
      |      root = Ox::Element.new('order')
      |
      |      root << Ox::Element.new('name') << name if name
      |      root << Ox::Element.new('company_name') << company_name if company_name
      |
      |      root
      |    end
      |  end
      |end })
  end
end
