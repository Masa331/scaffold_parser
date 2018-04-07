RSpec.describe 'arrays' do
  let(:scaffolds) { scaffold_schema('./spec/arrays/schema.xsd') }

  it 'scaffolds parser for type with various elements which can occure more than once' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def items
      |      array_of_at(ItemType, ['items', 'Item'])
      |    end
      |
      |    def payments
      |      submodel_at(PaymentType, 'payments')
      |    end
      |
      |    def documents
      |      array_of_at(String, ['documents', 'document'])
      |    end
      |
      |    def messages
      |      submodel_at(Messages, 'messages')
      |    end
      |
      |    def id
      |      array_of_at(String, ['ID'])
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:items] = items.map(&:to_h_with_attrs) if has? 'items'
      |      hash[:payments] = payments.to_h_with_attrs if has? 'payments'
      |      hash[:documents] = documents if has? 'documents'
      |      hash[:messages] = messages.to_h_with_attrs if has? 'messages'
      |      hash[:id] = id if has? 'ID'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for type including element which can occure more than once' do
    expect(scaffolds['parsers/payment_type.rb']).to eq_multiline(%{
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
  end

  it 'scaffolds parser for subtype which can occure more than once' do
    expect(scaffolds['parsers/payment.rb']).to eq_multiline(%{
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
  end

  it 'scaffolds parser for subtype with extension and element which can occure more than once' do
    expect(scaffolds['parsers/messages.rb']).to eq_multiline(%{
      |module Parsers
      |  class Messages < MessageType
      |    include BaseParser
      |
      |    def recipient
      |      array_of_at(RecipientType, ['recipient'])
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:recipient] = recipient.map(&:to_h_with_attrs) if has? 'recipient'
      |
      |      hash
      |      super.merge(hash)
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for subtype in extension which can occure more than once' do
    expect(scaffolds['parsers/recipient_type.rb']).to eq_multiline(%{
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

  it 'scaffolds parser subtype which is inherited with element which can occure more than once' do
    expect(scaffolds['parsers/message_type.rb']).to eq_multiline(%{
      |module Parsers
      |  class MessageType
      |    include BaseParser
      |
      |    def error
      |      array_of_at(String, ['error'])
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:error] = error if has? 'error'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type with various elements which can occure more than once' do
    expect(scaffolds['builders/order.rb']).to eq_multiline(%{
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
      |      if data.key? :items
      |        element = Ox::Element.new('items')
      |        data[:items].each { |i| element << ItemType.new('Item', i).builder }
      |        root << element
      |      end
      |      if data.key? :payments
      |        root << PaymentType.new('payments', data[:payments]).builder
      |      end
      |      if data.key? :documents
      |        element = Ox::Element.new('documents')
      |        data[:documents].map { |i| Ox::Element.new('document') << i }.each { |i| element << i }
      |        root << element
      |      end
      |      if data.key? :messages
      |        root << Messages.new('messages', data[:messages]).builder
      |      end
      |      if data.key? :id
      |        data[:id].map { |i| Ox::Element.new('ID') << i }.each { |i| root << i }
      |      end
      |
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type including element which can occure more than once' do
    expect(scaffolds['builders/payment_type.rb']).to eq_multiline(%{
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
  end

  it 'scaffolds builder for subtype which can occure more than once' do
    payment_parser = scaffolds['builders/payment.rb']
    expect(payment_parser).to eq_multiline(%{
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
  end

  it 'scaffolds builder for subtype with extension and element which can occure more than once' do
    expect(scaffolds['builders/messages.rb']).to eq_multiline(%{
      |module Builders
      |  class Messages < MessageType
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
      |      root
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for subtype in extension which can occure more than once' do
    expect(scaffolds['builders/recipient_type.rb']).to eq_multiline(%{
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

  it 'scaffolds builder for subtype which is inherited with element which can occure more than once' do
    expect(scaffolds['builders/message_type.rb']).to eq_multiline(%{
      |module Builders
      |  class MessageType
      |    include BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.respond_to? :attributes
      |        data.attributes.each { |k, v| root[k] = v }
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
  end
end
