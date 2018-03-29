RSpec.describe ScaffoldParser do
  let(:scaffolds) { scaffold_schema('./order.xsd', namespace: 'Something') }

  it 'scaffolds parser with given namespace' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Something
      |  module Parsers
      |    class Order
      |      include BaseParser
      |
      |      def name
      |        at 'name'
      |      end
      |
      |      def customer
      |        submodel_at(CustomerType, 'customer')
      |      end
      |
      |      def to_h_with_attrs
      |        hash = HashWithAttributes.new({}, attributes)
      |
      |        hash[:name] = name if has? 'name'
      |        hash[:customer] = customer.to_h_with_attrs if has? 'customer'
      |
      |        hash
      |      end
      |    end
      |  end
      |end })
  end

  it 'scaffolds builder with given namespace' do
    expect(scaffolds['builders/order.rb']).to eq_multiline(%{
      |module Something
      |  module Builders
      |    class Order
      |      include BaseBuilder
      |
      |      def builder
      |        root = Ox::Element.new(name)
      |        if data.respond_to? :attributes
      |          data.attributes.each { |k, v| root[k] = v }
      |        end
      |
      |        root << build_element('name', data[:name]) if data.key? :name
      |        if data.key? :customer
      |          root << CustomerType.new('customer', data[:customer]).builder
      |        end
      |
      |        root
      |      end
      |    end
      |  end
      |end })
  end
end
