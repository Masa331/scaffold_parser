RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./spec/element_refs/schema.xsd') }

  it 'scaffolds parser for type referencing subtypes from included schema' do
    expect(scaffolds['parsers/ord/order.rb']).to eq_multiline(%{
      |module Parsers
      |  module Ord
      |    class Order
      |      include ParserCore::BaseParser
      |
      |      def name
      |        at 'ord:name'
      |      end
      |
      |      def item
      |        submodel_at(Cmn::ItemType, 'cmn:item')
      |      end
      |
      |      def to_h_with_attrs
      |        hash = ParserCore::HashWithAttributes.new({}, attributes)
      |
      |        hash[:name] = name if has? 'ord:name'
      |        hash[:item] = item.to_h_with_attrs if has? 'cmn:item'
      |
      |        hash
      |      end
      |    end
      |  end
      |end })
  end
end
