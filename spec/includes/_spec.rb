RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./spec/includes/schema.xsd') }

  it 'scaffolds parser for type referencing subtypes from included schema' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def title
      |      at 'title'
      |    end
      |
      |    def title2
      |      at 'title2'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:title] = title if has? 'title'
      |      hash[:title2] = title2 if has? 'title2'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for type defined in included schema' do
    expect(scaffolds['parsers/person.rb']).to eq_multiline(%{
      |module Parsers
      |  class Person
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

  xit 'builder scaffolder output matches template' do
    codes = scaffold_schema('./spec/includes/schema.xsd')

    order_builder = codes['builders/order.rb']
    expect(order_builder).to eq_multiline(%{
      |require 'builders/base_builder'
      |
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
      |      root << build_element('title', data[:title]) if data.key? :title
      |      root << build_element('title2', data[:title2]) if data.key? :title2
      |
      |      root
      |    end
      |  end
      |end })
  end
end
