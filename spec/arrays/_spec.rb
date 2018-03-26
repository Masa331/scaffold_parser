RSpec.describe 'arrays' do
  it 'parser scaffolder matches template' do
    codes = scaffold_schema('./spec/arrays/schema.xsd')

    order_parser = codes['parsers/order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |require 'parsers/payment_type'
      |require 'parsers/messages'
      |require 'parsers/item_type'
      |
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def payments
      |      submodel_at(PaymentType, 'payments')
      |    end
      |
      |    def messages
      |      submodel_at(Messages, 'messages')
      |    end
      |
      |    def items
      |      array_of_at(ItemType, ['items', 'Item'])
      |    end
      |
      |    def documents
      |      array_of_at(String, ['documents', 'document'])
      |    end
      |
      |    def id
      |      array_of_at(String, ['ID'])
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:payments] = payments.to_h_with_attrs if has? 'payments'
      |      hash[:messages] = messages.to_h_with_attrs if has? 'messages'
      |      hash[:items] = items.map(&:to_h_with_attrs) if has? 'items'
      |      hash[:documents] = documents if has? 'documents'
      |      hash[:id] = id if has? 'ID'
      |
      |      hash
      |    end
      |  end
      |end })

    payment_type_parser = codes['parsers/payment_type.rb']
    expect(payment_type_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |require 'parsers/payment'
      |
      |module Parsers
      |  class PaymentType
      |    include BaseParser
      |
      |    def payments_list
      |      array_of_at(Payment, ['payments_list', 'payment'])
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:payments_list] = payments_list.map(&:to_h_with_attrs) if has? 'payments_list'
      |
      |      hash
      |    end
      |  end
      |end })

    payment_parser = codes['parsers/payment.rb']
    expect(payment_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |
      |module Parsers
      |  class Payment
      |    include BaseParser
      |
      |    def amount
      |      at 'amount'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:amount] = amount if has? 'amount'
      |
      |      hash
      |    end
      |  end
      |end })

    messages_parser = codes['parsers/messages.rb']
    expect(messages_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |require 'parsers/recipient_type'
      |
      |module Parsers
      |  class Messages
      |    include BaseParser
      |
      |    def recipient
      |      array_of_at(RecipientType, ['recipient'])
      |    end
      |
      |    def error
      |      array_of_at(String, ['error'])
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:recipient] = recipient.map(&:to_h_with_attrs) if has? 'recipient'
      |      hash[:error] = error if has? 'error'
      |
      |      hash
      |    end
      |  end
      |end })

    recipient_type_parser = codes['parsers/recipient_type.rb']
    expect(recipient_type_parser).to eq_multiline(%{
      |require 'parsers/base_parser'
      |
      |module Parsers
      |  class RecipientType
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

  it 'builder scaffolder matches template' do
    codes = scaffold_schema('./spec/arrays/schema.xsd')

    order_parser = codes['builders/order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'builders/base_builder'
      |require 'builders/payment_type'
      |require 'builders/messages'
      |require 'builders/item_type'
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
      |      if data.key? :payments
      |        root << PaymentType.new('payments', data[:payments]).builder
      |      end
      |
      |      if data.key? :messages
      |        root << Messages.new('messages', data[:messages]).builder
      |      end
      |
      |      if data.key? :items
      |        element = Ox::Element.new('items')
      |        data[:items].each { |i| element << ItemType.new('Item', i).builder }
      |        root << element
      |      end
      |
      |      if data.key? :documents
      |        element = Ox::Element.new('documents')
      |        data[:documents].map { |i| Ox::Element.new('document') << i }.each { |i| element << i }
      |        root << element
      |      end
      |
      |      if data.key? :id
      |        data[:id].map { |i| Ox::Element.new('ID') << i }.each { |i| root << i }
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    payment_type_parser = codes['builders/payment_type.rb']
    expect(payment_type_parser).to eq_multiline(%{
      |require 'builders/base_builder'
      |require 'builders/payment'
      |
      |module Builders
      |  class PaymentType
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      if data.key? :payments_list
      |        element = Ox::Element.new('payments_list')
      |        data[:payments_list].each { |i| element << Payment.new('payment', i).builder }
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    payment_parser = codes['builders/payment.rb']
    expect(payment_parser).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class Payment
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('amount', data[:amount]) if data.key? :amount
      |
      |      root
      |    end
      |  end
      |end })

    messages_parser = codes['builders/messages.rb']
    expect(messages_parser).to eq_multiline(%{
      |require 'builders/base_builder'
      |require 'builders/recipient_type'
      |
      |module Builders
      |  class Messages
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
      |      end
      |
      |      if data.key? :recipient
      |        data[:recipient].each { |i| root << RecipientType.new('recipient', i).builder }
      |      end
      |
      |      if data.key? :error
      |        data[:error].map { |i| Ox::Element.new('error') << i }.each { |i| root << i }
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    recipient_type_parser = codes['builders/recipient_type.rb']
    expect(recipient_type_parser).to eq_multiline(%{
      |require 'builders/base_builder'
      |
      |module Builders
      |  class RecipientType
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
