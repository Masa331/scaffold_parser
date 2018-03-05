RSpec.describe 'complex types' do
  it 'parser scaffolder output matches template' do
    codes = scaffold_schema('./spec/complex_types/schema.xsd')

    order_parser = codes['order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'base_element'
      |require 'currency'
      |require 'customer_type'
      |
      |class Order
      |  include BaseElement
      |
      |  def currency
      |    submodel_at(Currency, :currency)
      |  end
      |
      |  def customer
      |    submodel_at(CustomerType, :customer)
      |  end
      |
      |  def customer2
      |    submodel_at(CustomerType, :customer2)
      |  end
      |
      |  def to_h
      |    { currency: currency.to_h,
      |      customer: customer.to_h,
      |      customer2: customer2.to_h
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    currency_parser = codes['currency.rb']
    expect(currency_parser).to eq_multiline(%{
      |require 'base_element'
      |
      |class Currency
      |  include BaseElement
      |
      |  def currency_id
      |    at :currencyId
      |  end
      |
      |  def to_h
      |    { currency_id: currency_id
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    customer_type_parser = codes['customer_type.rb']
    expect(customer_type_parser).to eq_multiline(%{
      |require 'base_element'
      |
      |class CustomerType
      |  include BaseElement
      |
      |  def name
      |    at :name
      |  end
      |
      |  def to_h
      |    { name: name
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
    codes = scaffold_schema('./spec/complex_types/schema.xsd')

    order_builder = codes['builders/order.rb']
    expect(order_builder).to eq_multiline(%{
      |require 'base_builder'
      |require 'currency'
      |require 'customer_type'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    attr_accessor :currency, :customer, :customer2
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << Currency.new(currency, 'currency').builder if currency
      |      root << CustomerType.new(customer, 'customer').builder if customer
      |      root << CustomerType.new(customer2, 'customer2').builder if customer2
      |
      |      root
      |    end
      |  end
      |end })

    currency_builder = codes['builders/currency.rb']
    expect(currency_builder).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class Currency
      |    include BaseBuilder
      |
      |    attr_accessor :currency_id
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << Ox::Element.new('currencyId') << currency_id if currency_id
      |
      |      root
      |    end
      |  end
      |end })

    customer_type_builder = codes['builders/customer_type.rb']
    expect(customer_type_builder).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class CustomerType
      |    include BaseBuilder
      |
      |    attr_accessor :name
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << Ox::Element.new('name') << name if name
      |
      |      root
      |    end
      |  end
      |end })
  end
end
