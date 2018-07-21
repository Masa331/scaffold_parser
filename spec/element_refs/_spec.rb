RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./spec/element_refs/schema.xsd') }

  it 'scaffolds parser for type referencing subtypes from included schema' do
    expect(scaffolds['parsers/ord/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  module Ord
    class Order
      include ParserCore::BaseParser

      def name
        at 'ord:name'
      end

      def name_attributes
        attributes_at 'ord:name'
      end

      def item
        submodel_at(Cmn::ItemType, 'cmn:item')
      end

      def to_h
        hash = {}
        hash[:attributes] = attributes

        hash[:name] = name if has? 'ord:name'
        hash[:name_attributes] = name_attributes if has? 'ord:name'
        hash[:item] = item.to_h if has? 'cmn:item'

        hash
      end
    end
  end
end
      CODE
    )
  end
end
