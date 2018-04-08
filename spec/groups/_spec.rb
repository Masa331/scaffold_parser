RSpec.describe 'simple types' do
  let(:scaffolds) { scaffold_schema('./spec/groups/schema.xsd') }

  it 'scaffolds parser for type including group' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |    include Configuration
      |
      |    def buyer
      |      submodel_at(Buyer, 'buyer')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:buyer] = buyer.to_h_with_attrs if has? 'buyer'
      |
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for type including group' do
    expect(scaffolds['parsers/buyer.rb']).to eq_multiline(%{
      |module Parsers
      |  class Buyer
      |    include BaseParser
      |    include Configuration
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
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for group' do
    expect(scaffolds['parsers/configuration.rb']).to eq_multiline(%{
      |module Parsers
      |  module Configuration
      |    def flag
      |      at 'flag'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:flag] = flag if has? 'flag'
      |
      |      hash
      |    end
      |  end
      |end })
  end
end
