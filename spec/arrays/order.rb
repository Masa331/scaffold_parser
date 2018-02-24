require 'base_element'
require 'payment_type'
require 'messages'
require 'item_type'

class Order
  include BaseElement

  def payments
    submodel_at(PaymentType, :payments)
  end

  def messages
    submodel_at(Messages, :messages)
  end

  def items
    array_of_at(ItemType, [:items, :Item])
  end

  def documents
    array_of_at(String, [:documents, :document])
  end

  def id
    array_of_at(String, [:ID])
  end

  def to_h
    { payments: payments.to_h,
      messages: messages.to_h,
      items: items.map(&:to_h),
      documents: documents,
      id: id
    }.delete_if { |k, v| v.nil? || v.empty? }
  end
end
