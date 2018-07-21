RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./spec/includes/schema.xsd') }

  it 'scaffolds parser for type referencing subtypes from included schema' do
    expect(scaffolds['parsers/order.rb']).to eq(
      |module Parsers
      |  class Order
      |    include ParserCore::BaseParser
      |
      |    def title
      |      at 'title'
      |    end
      |
      |    def title2
      |      at 'title2'
      |    end
      |
      |    def to_h
      |      hash[:attributes] = attributes
      |
      |      hash[:title] = title if has? 'title'
      |      hash[:title2] = title2 if has? 'title2'
      |
      |      hash
      |    end
      |  end
      end
  end

  it 'scaffolds parser for type defined in included schema' do
    expect(scaffolds['parsers/person.rb']).to eq(
      |module Parsers
      |  class Person
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
      end
  end

  it 'scaffolds builder for type referencing subtypes from included schema' do
    expect(scaffolds['builders/order.rb']).to eq(
      |module Builders
      |  class Order
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.key? :attributes
      |        data[:attributes].each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('title', data[:title]) if data.key? :title
      |      root << build_element('title2', data[:title2]) if data.key? :title2
      |
      |      root
      |    end
      |  end
      end
  end

  it 'scaffolds builder for type defined in included schema' do
    expect(scaffolds['builders/person.rb']).to eq(
      |module Builders
      |  class Person
      |    include ParserCore::BaseBuilder
      |
      |    def builder
      |      root = Ox::Element.new(name)
      |      if data.key? :attributes
      |        data[:attributes].each { |k, v| root[k] = v }
      |      end
      |
      |      root << build_element('name', data[:name]) if data.key? :name
      |
      |      root
      |    end
      |  end
      end
  end
end
