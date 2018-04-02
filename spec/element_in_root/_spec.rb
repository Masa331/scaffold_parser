RSpec.describe 'simple types' do
  let(:scaffolds) { scaffold_schema('./spec/element_in_root/schema.xsd') }

  it 'scaffolds parser for schema with element in root' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
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

  # it 'scaffolds builder for type including only basic elements' do
  #   expect(scaffolds['builders/order.rb']).to eq_multiline(%{
  #     |module Builders
  #     |  class Order
  #     |    include BaseBuilder
  #     |
  #     |    def builder
  #     |      root = Ox::Element.new(name)
  #     |      if data.respond_to? :attributes
  #     |        data.attributes.each { |k, v| root[k] = v }
  #     |      end
  #     |
  #     |      root << build_element('name', data[:name]) if data.key? :name
  #     |      root << build_element('title', data[:title]) if data.key? :title
  #     |      root << build_element('Total', data[:total]) if data.key? :total
  #     |
  #     |      root
  #     |    end
  #     |  end
  #     |end })
  # end
end
