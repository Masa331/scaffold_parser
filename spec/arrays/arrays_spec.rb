RSpec.describe 'arrays' do
  it 'parser scaffolder matches template' do
    codes = scaffold_schema('./spec/arrays/schema.xsd')

    order_parser = codes['order.rb']
    expect(order_parser).to eq_multiline(%{
      |require 'base_element'
      |require 'payment_type'
      |require 'messages'
      |require 'item_type'
      |
      |class Order
      |  include BaseElement
      |
      |  def payments
      |    submodel_at(PaymentType, :payments)
      |  end
      |
      |  def messages
      |    submodel_at(Messages, :messages)
      |  end
      |
      |  def items
      |    array_of_at(ItemType, [:items, :Item])
      |  end
      |
      |  def documents
      |    array_of_at(String, [:documents, :document])
      |  end
      |
      |  def id
      |    array_of_at(String, [:ID])
      |  end
      |
      |  def to_h
      |    { payments: payments.to_h,
      |      messages: messages.to_h,
      |      items: items.map(&:to_h),
      |      documents: documents,
      |      id: id
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    payment_type_parser = codes['payment_type.rb']
    expect(payment_type_parser).to eq_multiline(%{
      |require 'base_element'
      |require 'payment'
      |
      |class PaymentType
      |  include BaseElement
      |
      |  def payments_list
      |    array_of_at(Payment, [:payments_list, :payment])
      |  end
      |
      |  def to_h
      |    { payments_list: payments_list.map(&:to_h)
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    payment_parser = codes['payment.rb']
    expect(payment_parser).to eq_multiline(%{
      |require 'base_element'
      |
      |class Payment
      |  include BaseElement
      |
      |  def amount
      |    at :amount
      |  end
      |
      |  def to_h
      |    { amount: amount
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    messages_parser = codes['messages.rb']
    expect(messages_parser).to eq_multiline(%{
      |require 'base_element'
      |require 'recipient_type'
      |
      |class Messages
      |  include BaseElement
      |
      |  def recipient
      |    array_of_at(RecipientType, [:recipient])
      |  end
      |
      |  def error
      |    array_of_at(String, [:error])
      |  end
      |
      |  def to_h
      |    { recipient: recipient.map(&:to_h),
      |      error: error
      |    }.delete_if { |k, v| v.nil? || v.empty? }
      |  end
      |end })

    recipient_type_parser = codes['recipient_type.rb']
    expect(recipient_type_parser).to eq_multiline(%{
      |require 'base_element'
      |
      |class RecipientType
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
end
