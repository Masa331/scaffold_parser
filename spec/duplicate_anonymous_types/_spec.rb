RSpec.describe 'schema with duplicate and same named anonymous complex types' do
  let(:scaffolds) { scaffold_schema('./spec/duplicate_anonymous_types/schema.xsd') }

  it 'scaffolds parser for order' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include ParserCore::BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer, 'buyer')
      |    end
      |
      |    def seller
      |      submodel_at(Seller, 'seller')
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:buyer] = buyer.to_h if has? 'buyer'
      |      hash[:seller] = seller.to_h if has? 'seller'
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
      |    include ParserCore::BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer2, 'buyer')
      |    end
      |
      |    def seller
      |      submodel_at(Seller, 'seller')
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:buyer] = buyer.to_h if has? 'buyer'
      |      hash[:seller] = seller.to_h if has? 'seller'
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
      |    include ParserCore::BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer3, 'buyer')
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:buyer] = buyer.to_h if has? 'buyer'
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
      |    include ParserCore::BaseParser
      |
      |    def buyer
      |      submodel_at(Buyer3, 'buyer')
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:buyer] = buyer.to_h if has? 'buyer'
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
      |    include ParserCore::BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
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
      |    include ParserCore::BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def company_id
      |      at 'company_id'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
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
      |    include ParserCore::BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def referer
      |      at 'referer'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
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
