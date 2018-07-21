RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./spec/includes/schema.xsd') }

  it 'scaffolds parser for type referencing subtypes from included schema' do
    expect(scaffolds['parsers/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser

    def title
      at 'title'
    end

    def title_attributes
      attributes_at 'title'
    end

    def title2
      at 'title2'
    end

    def title2_attributes
      attributes_at 'title2'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:title] = title if has? 'title'
      hash[:title_attributes] = title_attributes if has? 'title'
      hash[:title2] = title2 if has? 'title2'
      hash[:title2_attributes] = title2_attributes if has? 'title2'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for type defined in included schema' do
    expect(scaffolds['parsers/person.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Person
    include ParserCore::BaseParser

    def name
      at 'name'
    end

    def name_attributes
      attributes_at 'name'
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:name] = name if has? 'name'
      hash[:name_attributes] = name_attributes if has? 'name'

      hash
    end
  end
end
      CODE
    )
  end

  it 'scaffolds builder for type referencing subtypes from included schema' do
    expect(scaffolds['builders/order.rb']).to eq(
      <<-CODE.chomp
module Builders
  class Order
    include ParserCore::BaseBuilder

    def builder
      root = Ox::Element.new(name)
      if data.key? :attributes
        data[:attributes].each { |k, v| root[k] = v }
      end

      root << build_element('title', data[:title], data[:title_attributes]) if data.key? :title
      root << build_element('title2', data[:title2], data[:title2_attributes]) if data.key? :title2

      root
    end
  end
end
      CODE
    )
  end

  it 'scaffolds builder for type defined in included schema' do
    expect(scaffolds['builders/person.rb']).to eq(
      <<-CODE.chomp
module Builders
  class Person
    include ParserCore::BaseBuilder

    def builder
      root = Ox::Element.new(name)
      if data.key? :attributes
        data[:attributes].each { |k, v| root[k] = v }
      end

      root << build_element('name', data[:name], data[:name_attributes]) if data.key? :name

      root
    end
  end
end
      CODE
    )
  end
end
