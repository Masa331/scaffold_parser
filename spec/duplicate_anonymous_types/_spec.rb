RSpec.describe 'schema with duplicate and same named anonymous complex types' do
  let(:scaffolds) { scaffold_schema('./spec/duplicate_anonymous_types/schema.xsd') }

  it 'scaffolds 12 classes total' do
    expected = ["parsers/order.rb",
       "builders/order.rb",
       "builders/reservation.rb",
       "parsers/base_parser.rb",
       "builders/base_builder.rb",
       "requires.rb",
       "hash_with_attrs.rb",
       "mega.rb",
       "parsers/invoice.rb",
       "parsers/reservation.rb",
       "builders/invoice.rb",
       "parsers/offer.rb",
       "builders/offer.rb",
       "parsers/buyer.rb",
       "builders/buyer.rb",
       "parsers/seller.rb",
       "builders/seller.rb",
       "parsers/buyer2.rb",
       "builders/buyer2.rb",
       "parsers/buyer3.rb",
       "builders/buyer3.rb"]

    expect(scaffolds.keys.sort).to eq(expected.sort)
  end

  it 'scaffolds parser for order' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer, 'buyer')
      |    end
      |
      |    def seller
      |      submodel_at(Seller, 'seller')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:buyer] = buyer.to_h_with_attrs if has? 'buyer'
      |      hash[:seller] = seller.to_h_with_attrs if has? 'seller'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for invoice' do
    expect(scaffolds['parsers/invoice.rb']).to eq_multiline(%{
      |module Parsers
      |  class Invoice
      |    include BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer2, 'buyer')
      |    end
      |
      |    def seller
      |      submodel_at(Seller, 'seller')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:buyer] = buyer.to_h_with_attrs if has? 'buyer'
      |      hash[:seller] = seller.to_h_with_attrs if has? 'seller'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for offer' do
    expect(scaffolds['parsers/offer.rb']).to eq_multiline(%{
      |module Parsers
      |  class Offer
      |    include BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer3, 'buyer')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:buyer] = buyer.to_h_with_attrs if has? 'buyer'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for offer' do
    expect(scaffolds['parsers/reservation.rb']).to eq_multiline(%{
      |module Parsers
      |  class Reservation
      |    include BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer3, 'buyer')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:buyer] = buyer.to_h_with_attrs if has? 'buyer'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for buyer with only name' do
    expect(scaffolds['parsers/buyer.rb']).to eq_multiline(%{
      |module Parsers
      |  class Buyer
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

  it 'scaffolds parser for buyer with name and company_id' do
    expect(scaffolds['parsers/buyer2.rb']).to eq_multiline(%{
      |module Parsers
      |  class Buyer2
      |    include BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def company_id
      |      at 'company_id'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |      hash[:company_id] = company_id if has? 'company_id'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for buyer with name and referer' do
    expect(scaffolds['parsers/buyer3.rb']).to eq_multiline(%{
      |module Parsers
      |  class Buyer3
      |    include BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def referer
      |      at 'referer'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |      hash[:referer] = referer if has? 'referer'
      |
      |      hash
      |    end
      |  end
      |end })
  end
end
