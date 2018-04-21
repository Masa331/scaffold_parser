RSpec.describe 'simple types' do
  it 'parses one member group allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:group name="configuration">
      |    <xs:all>
      |      <xs:element name="flag" type="flag">
      |      </xs:element>
      |    </xs:all>
      |  </xs:group>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/groups/configuration.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  module Groups
      |    module Configuration
      |      def flag
      |        submodel_at(Flag, 'flag')
      |      end
      |
      |      def to_h_with_attrs
      |        hash = HashWithAttributes.new({}, attributes)
      |
      |        hash[:flag] = flag.to_h_with_attrs if has? 'flag'
      |
      |        hash
      |      end
      |    end
      |  end
      |end })
  end

  it 'parses complex type allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |    <xs:sequence>
      |      <xs:group ref="configuration"/>
      |    </xs:sequence>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |    include Groups::Configuration
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })
  end

  it 'parses complex type allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:complexType name="order">
      |    <xs:group ref="configuration"/>
      |  </xs:complexType>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |    include Groups::Configuration
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })
  end

  it 'parses complex type allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:element name="order" minOccurs="0">
      |    <xs:complexType>
      |      <xs:group ref="configuration"/>
      |    </xs:complexType>
      |  </xs:element>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |    include Groups::Configuration
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })
  end

  it 'parses complex type allright' do
    schema = multiline(%{
      |<?xml version="1.0" encoding="UTF-8"?>
      |<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
      |  <xs:group name="configuration">
      |    <xs:sequence>
      |      <xs:element name="flag" type="xs:string">
      |      </xs:element>
      |      <xs:element name="flag2" type="xs:string">
      |      </xs:element>
      |    </xs:sequence>
      |  </xs:group>
      |</xs:schema> })

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/groups/configuration.rb']
    expect(scaffold).to eq_multiline(%{
      |module Parsers
      |  module Groups
      |    module Configuration
      |      def flag
      |        at 'flag'
      |      end
      |
      |      def flag2
      |        at 'flag2'
      |      end
      |
      |      def to_h_with_attrs
      |        hash = HashWithAttributes.new({}, attributes)
      |
      |        hash[:flag] = flag if has? 'flag'
      |        hash[:flag2] = flag2 if has? 'flag2'
      |
      |        hash
      |      end
      |    end
      |  end
      |end })
  end

  let(:scaffolds) { scaffold_schema('./spec/groups/schema.xsd') }

  it 'scaffolds parser for type including group' do
    expect(scaffolds['parsers/order.rb']).to eq_multiline(%{
      |module Parsers
      |  class Order
      |    include BaseParser
      |    include Groups::Configuration
      |
      |    def buyer
      |      submodel_at(Buyer, 'buyer')
      |    end
      |
      |    def to_h_with_attrs
      |      hash = HashWithAttributes.new({}, attributes)
      |
      |      hash[:buyer] = buyer.to_h_with_attrs if has? 'buyer'
      |
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for type including group' do
    expect(scaffolds['parsers/buyer.rb']).to eq_multiline(%{
      |module Parsers
      |  class Buyer
      |    include BaseParser
      |    include Groups::Configuration
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
      |      mega.inject(hash) { |memo, r| memo.merge r }
      |    end
      |  end
      |end })
  end

  it 'scaffolds parser for group' do
    expect(scaffolds['parsers/groups/configuration.rb']).to eq_multiline(%{
      |module Parsers
      |  module Groups
      |    module Configuration
      |      def flag
      |        at 'flag'
      |      end
      |
      |      def to_h_with_attrs
      |        hash = HashWithAttributes.new({}, attributes)
      |
      |        hash[:flag] = flag if has? 'flag'
      |
      |        hash
      |      end
      |    end
      |  end
      |end })
  end
end
