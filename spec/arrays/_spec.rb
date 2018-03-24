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
      |      submodel_at(PaymentType, :payments)
      |    end
      |
      |    def messages
      |      submodel_at(Messages, :messages)
      |    end
      |
      |    def items
      |      array_of_at(ItemType, [:items, :Item])
      |    end
      |
      |    def documents
      |      array_of_at(String, [:documents, :document])
      |    end
      |
      |    def id
      |      array_of_at(String, [:ID])
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:payments] = payments.to_h if raw.key? :payments
      |      hash[:messages] = messages.to_h if raw.key? :messages
      |      hash[:items] = items.map(&:to_h) if raw.key? :items
      |      hash[:documents] = documents if raw.key? :documents
      |      hash[:id] = id if raw.key? :ID
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
      |      array_of_at(Payment, [:payments_list, :payment])
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:payments_list] = payments_list.map(&:to_h) if raw.key? :payments_list
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
      |      at :amount
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:amount] = amount if raw.key? :amount
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
      |      array_of_at(RecipientType, [:recipient])
      |    end
      |
      |    def error
      |      array_of_at(String, [:error])
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:recipient] = recipient.map(&:to_h) if raw.key? :recipient
      |      hash[:error] = error if raw.key? :error
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
      |      at :name
      |    end
      |
      |    def to_h
      |      hash = {}
      |
      |      hash[:name] = name if raw.key? :name
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :payments
      |        root << PaymentType.new(attributes[:payments], 'payments').builder
      |      end
      |
      |      if attributes.key? :messages
      |        root << Messages.new(attributes[:messages], 'messages').builder
      |      end
      |
      |      if attributes.key? :items
      |        element = Ox::Element.new('items')
      |        attributes[:items].each { |i| element << ItemType.new(i, 'Item').builder }
      |        root << element
      |      end
      |
      |      if attributes.key? :documents
      |        element = Ox::Element.new('documents')
      |        attributes[:documents].map { |i| Ox::Element.new('document') << i }.each { |i| element << i }
      |        root << element
      |      end
      |
      |      if attributes.key? :id
      |        attributes[:id].map { |i| Ox::Element.new('ID') << i }.each { |i| root << i }
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :payments_list
      |        element = Ox::Element.new('payments_list')
      |        attributes[:payments_list].each { |i| element << Payment.new(i, 'payment').builder }
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :amount
      |        element = Ox::Element.new('amount')
      |        element << attributes[:amount] if attributes[:amount]
      |        root << element
      |      end
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :recipient
      |        attributes[:recipient].each { |i| root << RecipientType.new(i, 'recipient').builder }
      |      end
      |
      |      if attributes.key? :error
      |        attributes[:error].map { |i| Ox::Element.new('error') << i }.each { |i| root << i }
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
      |      root = Ox::Element.new(element_name)
      |
      |      if attributes.key? :name
      |        element = Ox::Element.new('name')
      |        element << attributes[:name] if attributes[:name]
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end
end
