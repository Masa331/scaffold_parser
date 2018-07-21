RSpec.describe 'simple types' do
  let(:scaffolds) { scaffold_schema('./spec/element_in_root/schema.xsd') }

  it 'scaffolds parser for schema with element in root' do
    expect(scaffolds['parsers/order.rb']).to eq(
      module Parsers
        class Order
          include ParserCore::BaseParser
      
          def name
            at 'name'
          end
      
          def to_h
            hash[:attributes] = attributes
      
            hash[:name] = name if has? 'name'
      
            hash
          end
        end
      end
  end
end
