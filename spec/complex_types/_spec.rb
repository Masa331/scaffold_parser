RSpec.describe 'complex types' do
  it 'parser scaffolder output matches template' do
    codes = scaffold_schema('./spec/complex_types/schema.xsd')

    order_parser = codes['parsers/order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |require 'parsers/currency'
      |require 'parsers/customer_type'
      |
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def currency
      |      submodel_at(Currency, 'currency')
      |    end
      |
      |    def customer
      |      submodel_at(CustomerType, 'customer')
      |    end
      |
      |    def customer2
      |      submodel_at(CustomerType, 'customer2')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:currency] = currency.to_h_with_attrs if has? 'currency'
      |      hash[:customer] = customer.to_h_with_attrs if has? 'customer'
      |      hash[:customer2] = customer2.to_h_with_attrs if has? 'customer2'
      |
      |      hash
      |    end
      |  end
      |end })

    currency_parser = codes['parsers/currency.rb']
    expect(currency_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |
      |module Parsers
      |  class Currency
      |    include BaseParser
      |
      |    def currency_id
      |      at 'currencyId'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:currency_id] = currency_id if has? 'currencyId'
      |
      |      hash
      |    end
      |  end
      |end })

    customer_type_parser = codes['parsers/customer_type.rb']
    expect(customer_type_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |
      |module Parsers
      |  class CustomerType
      |    include BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder output matches template' do
    codes = scaffold_schema('./spec/complex_types/schema.xsd')

    order_builder = codes['builders/order.rb']
    expect(order_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |require 'builders/currency'
      |require 'builders/customer_type'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      if data.key? :currency
      |        root << Currency.new('currency', data[:currency]).builder
      |      end
      |
      |      if data.key? :customer
      |        root << CustomerType.new('customer', data[:customer]).builder
      |      end
      |
      |      if data.key? :customer2
      |        root << CustomerType.new('customer2', data[:customer2]).builder
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    currency_builder = codes['builders/currency.rb']
    expect(currency_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class Currency
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('currencyId', data[:currency_id]) if data.key? :currency_id
      |
      |      root
      |    end
      |  end
      |end })

    customer_type_builder = codes['builders/customer_type.rb']
    expect(customer_type_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class CustomerType
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('name', data[:name]) if data.key? :name
      |
      |      root
      |    end
      |  end
      |end })
  end
end
