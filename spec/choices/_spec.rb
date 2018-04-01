RSpec.describe 'choices' do
  it 'parser scaffolder matches template' do
    parser_code = parser_for('./spec/choices/schema.xsd', 'parsers/order.rb')

    expect(parser_code).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |
      |    def name
      |      at 'name'
      |    end
      |
      |    def company_name
      |      at 'company_name'
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:name] = name if has? 'name'
      |      hash[:company_name] = company_name if has? 'company_name'
      |
      |      hash
      |    end
      |  end
      |end })
  end

  xit 'builder scaffolder matches template' do
    builder_code = builder_for('./spec/choices/schema.xsd', 'builders/order.rb')

    expect(builder_code).to eq_multiline(%{
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
      |      root << build_element('company_name', data[:company_name]) if data.key? :company_name
      |
      |      root
      |    end
      |  end
      |end })
  end
end
