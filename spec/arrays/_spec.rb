RSpec.describe 'arrays' do
  it 'parser scaffolder matches template' do
    codes = scaffold_schema('./spec/arrays/schema.xsd')

    order_parser = codes['parsers/order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'base_parser'
      |require 'payment_type'
      |require 'messages'
      |require 'item_type'
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
      |      { payments: payments.to_h,
      |        messages: messages.to_h,
      |        items: items.map(&:to_h),
      |        documents: documents,
      |        id: id
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    payment_type_parser = codes['parsers/payment_type.rb']
    expect(payment_type_parser).to eq_multiline(%{
      |require 'base_parser'
      |require 'payment'
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
      |      { payments_list: payments_list.map(&:to_h)
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    payment_parser = codes['parsers/payment.rb']
    expect(payment_parser).to eq_multiline(%{
      |require 'base_parser'
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
      |      { amount: amount
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    messages_parser = codes['parsers/messages.rb']
    expect(messages_parser).to eq_multiline(%{
      |require 'base_parser'
      |require 'recipient_type'
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
      |      { recipient: recipient.map(&:to_h),
      |        error: error
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })

    recipient_type_parser = codes['parsers/recipient_type.rb']
    expect(recipient_type_parser).to eq_multiline(%{
      |require 'base_parser'
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
      |      { name: name
      |      }.delete_if { |k, v| v.nil? || v.empty? }
      |    end
      |  end
      |end })
  end

  it 'builder scaffolder matches template' do
    codes = scaffold_schema('./spec/arrays/schema.xsd')

    order_parser = codes['builders/order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'base_builder'
      |require 'payment_type'
      |require 'messages'
      |require 'item_type'
      |
      |module Builders
      |  class Order
      |    include BaseBuilder
      |
      |    attr_accessor :payments, :messages, :items, :documents, :id
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << PaymentType.new(payments, 'payments').builder if payments
      |      root << Messages.new(messages, 'messages').builder if messages
      |
      |      if items
      |        element = Ox::Element.new('items')
      |        items.each { |i| element << ItemType.new(i, 'Item').builder }
      |        root << element
      |      end
      |
      |      if documents
      |        element = Ox::Element.new('documents')
      |        documents.map { |i| Ox::Element.new('document') << i }.each { |i| element << i }
      |        root << element
      |      end
      |
      |      if id
      |        id.map { |i| Ox::Element.new('ID') << i }.each { |i| root << i }
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    payment_type_parser = codes['builders/payment_type.rb']
    expect(payment_type_parser).to eq_multiline(%{
      |require 'base_builder'
      |require 'payment'
      |
      |module Builders
      |  class PaymentType
      |    include BaseBuilder
      |
      |    attr_accessor :payments_list
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      if payments_list
      |        element = Ox::Element.new('payments_list')
      |        payments_list.each { |i| element << Payment.new(i, 'payment').builder }
      |        root << element
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    payment_parser = codes['builders/payment.rb']
    expect(payment_parser).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class Payment
      |    include BaseBuilder
      |
      |    attr_accessor :amount
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << (Ox::Element.new('amount') << amount) if amount
      |
      |      root
      |    end
      |  end
      |end })

    messages_parser = codes['builders/messages.rb']
    expect(messages_parser).to eq_multiline(%{
      |require 'base_builder'
      |require 'recipient_type'
      |
      |module Builders
      |  class Messages
      |    include BaseBuilder
      |
      |    attr_accessor :recipient, :error
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      if recipient
      |        recipient.each { |i| root << RecipientType.new(i, 'recipient').builder }
      |      end
      |
      |      if error
      |        error.map { |i| Ox::Element.new('error') << i }.each { |i| root << i }
      |      end
      |
      |      root
      |    end
      |  end
      |end })

    recipient_type_parser = codes['builders/recipient_type.rb']
    expect(recipient_type_parser).to eq_multiline(%{
      |require 'base_builder'
      |
      |module Builders
      |  class RecipientType
      |    include BaseBuilder
      |
      |    attr_accessor :name
      |
      |    def builder
      |      root = Ox::Element.new(element_name)
      |
      |      root << (Ox::Element.new('name') << name) if name
      |
      |      root
      |    end
      |  end
      |end })
  end
end