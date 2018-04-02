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
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for type including group' do
    expect(scaffolds['parsers/buyer.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |    include Configuration
      |  end
      |end })
  end

  it 'scaffolds parser for group' do
    expect(scaffolds['parsers/group.rb']).to eq_multiline(%{
      |module Parsers
      |  class Group
      |    include BaseParser
      |
      |    def flag
      |      at 'flag'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:flag] = flag.to_h_with_attrs if has? 'flag'
      |
      |      hash
      |    end
      |  end
      |end })
  end
end
