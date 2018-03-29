RSpec.describe 'simple types' do
  let(:scaffolds) { scaffold_schema('./spec/simple_types/schema.xsd') }

  it 'scaffolds parser for type including only basic elements' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def title
      |      at 'title'
      |    end
      |
      |    def total
      |      at 'Total'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |      hash[:title] = title if has? 'title'
      |      hash[:total] = total if has? 'Total'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder for type including only basic elements' do
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
      |      root << build_element('name', data[:name]) if data.key? :name
      |      root << build_element('title', data[:title]) if data.key? :title
      |      root << build_element('Total', data[:total]) if data.key? :total
      |
      |      root
      |    end
      |  end
      |end })
  end
end
