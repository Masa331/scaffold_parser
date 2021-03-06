RSpec.describe 'simple types' do
  it 'group with namespaces' do
    schema = <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
        <xs:schema
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
          targetNamespace="http://www.stormware.cz/schema/version_2/type.xsd"
          elementFormDefault="qualified" >

        <xs:complexType name="order">
          <xs:sequence>
            <xs:element name="name"/>
            <xs:group ref="typ:secondGroup"/>
          </xs:sequence>
        </xs:complexType>
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  class Order
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

  it 'scaffolds parser for type referencing subtypes from included schema' do
    scaffolds = scaffold_schema('./spec/groups/schema2.xsd')

    expect(scaffolds['parsers/ord/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  module Ord
    class Order
      include ParserCore::BaseParser
      include Cmn::Groups::SecondGroup

      def to_h
        hash = {}
        hash[:attributes] = attributes

        mega.inject(hash) { |memo, r| memo.merge r }
      end
    end
  end
end
      CODE
    )

    expect(scaffolds['parsers/cmn/groups/second_group.rb']).to eq(
      <<-CODE.chomp
module Parsers
  module Cmn
    module Groups
      module SecondGroup
        def account_no
          at 'cmn:accountNo'
        end

        def account_no_attributes
          attributes_at 'cmn:accountNo'
        end

        def bank_code
          at 'cmn:bankCode'
        end

        def bank_code_attributes
          attributes_at 'cmn:bankCode'
        end

        def to_h
          hash = {}
          hash[:attributes] = attributes

          hash[:account_no] = account_no if has? 'cmn:accountNo'
          hash[:account_no_attributes] = account_no_attributes if has? 'cmn:accountNo'
          hash[:bank_code] = bank_code if has? 'cmn:bankCode'
          hash[:bank_code_attributes] = bank_code_attributes if has? 'cmn:bankCode'

          hash
        end
      end
    end
  end
end
      CODE
    )
  end

  it 'group with namespaces' do
    schema = <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
        <xs:schema
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
          xmlns="http://www.stormware.cz/schema/version_2/type.xsd"
          targetNamespace="http://www.stormware.cz/schema/version_2/type.xsd"
          elementFormDefault="qualified" >

        <xs:complexType name="order">
          <xs:sequence>
            <xs:group ref="myGroupOfAccount"/>
            <xs:group ref="typ:secondGroup"/>
          </xs:sequence>
        </xs:complexType>

        <xs:group name="myGroupOfAccount">
          <xs:all>
            <xs:element name="accountNo"/>
            <xs:element name="bankCode"/>
          </xs:all>
        </xs:group>

        <xs:group name="secondGroup">
          <xs:all>
            <xs:element name="accountNo"/>
            <xs:element name="bankCode"/>
          </xs:all>
        </xs:group>
      </xs:schema>
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/typ/groups/my_group_of_account.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  module Typ
    module Groups
      module MyGroupOfAccount
        def account_no
          at 'typ:accountNo'
        end

        def account_no_attributes
          attributes_at 'typ:accountNo'
        end

        def bank_code
          at 'typ:bankCode'
        end

        def bank_code_attributes
          attributes_at 'typ:bankCode'
        end

        def to_h
          hash = {}
          hash[:attributes] = attributes

          hash[:account_no] = account_no if has? 'typ:accountNo'
          hash[:account_no_attributes] = account_no_attributes if has? 'typ:accountNo'
          hash[:bank_code] = bank_code if has? 'typ:bankCode'
          hash[:bank_code_attributes] = bank_code_attributes if has? 'typ:bankCode'

          hash
        end
      end
    end
  end
end
      CODE
    )

    scaffold = Hash[scaffolds]['parsers/typ/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  module Typ
    class Order
      include ParserCore::BaseParser
      include Typ::Groups::MyGroupOfAccount
      include Typ::Groups::SecondGroup

      def to_h
        hash = {}
        hash[:attributes] = attributes

        mega.inject(hash) { |memo, r| memo.merge r }
      end
    end
  end
end
      CODE
    )
  end

  it 'parses one member group allright' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:group name="configuration">
          <xs:all>
            <xs:element name="flag" type="flag">
            </xs:element>
          </xs:all>
        </xs:group>
        <xs:complexType name="flag">
          <xs:all>
            <xs:element name="flag"/>
          </xs:all>
        </xs:complexType>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/groups/configuration.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  module Groups
    module Configuration
      def flag
        submodel_at(Flag, 'flag')
      end

      def to_h
        hash = {}
        hash[:attributes] = attributes

        hash[:flag] = flag.to_h if has? 'flag'

        hash
      end
    end
  end
end
      CODE
    )

    scaffold = Hash[scaffolds]['builders/groups/configuration.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Builders
  module Groups
    module Configuration
      def builder
        root = Ox::Element.new(name)
        root = add_attributes_and_namespaces(root)

        if data.key? :flag
          root << Flag.new('flag', data[:flag]).builder
        end

        root
      end
    end
  end
end
      CODE
    )
  end

  it 'group inside a sequence' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:complexType name="order">
          <xs:sequence>
            <xs:group ref="configuration"/>
          </xs:sequence>
        </xs:complexType>
      
        <xs:group name="configuration">
          <xs:sequence>
            <xs:element name="flag"/>
          </xs:sequence>
        </xs:group>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser
    include Groups::Configuration

    def to_h
      hash = {}
      hash[:attributes] = attributes

      mega.inject(hash) { |memo, r| memo.merge r }
    end
  end
end
      CODE
    )

    scaffold = Hash[scaffolds]['builders/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Builders
  class Order
    include ParserCore::BaseBuilder
    include Groups::Configuration

    def builder
      root = Ox::Element.new(name)
      root = add_attributes_and_namespaces(root)

      mega.each do |r|
        r.nodes.each { |n| root << n }
      end

      root
    end
  end
end
      CODE
    )
  end

  it 'group directly inside a complex type' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:complexType name="order">
          <xs:group ref="configuration"/>
        </xs:complexType>
      
        <xs:group name="configuration">
          <xs:sequence>
            <xs:element name="flag"/>
          </xs:sequence>
        </xs:group>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser
    include Groups::Configuration

    def to_h
      hash = {}
      hash[:attributes] = attributes

      mega.inject(hash) { |memo, r| memo.merge r }
    end
  end
end
      CODE
    )
  end

  it 'group in element' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:element name="order" minOccurs="0">
          <xs:complexType>
            <xs:group ref="configuration"/>
          </xs:complexType>
        </xs:element>
      
        <xs:group name="configuration">
          <xs:sequence>
            <xs:element name="flag"/>
          </xs:sequence>
        </xs:group>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/order.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser
    include Groups::Configuration

    def to_h
      hash = {}
      hash[:attributes] = attributes

      mega.inject(hash) { |memo, r| memo.merge r }
    end
  end
end
      CODE
    )
  end

  it 'parses complex type allright' do
    schema =
    <<-XSD
      <?xml version="1.0" encoding="UTF-8"?>
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:group name="configuration">
          <xs:sequence>
            <xs:element name="flag" type="xs:string">
            </xs:element>
            <xs:element name="flag2" type="xs:string">
            </xs:element>
          </xs:sequence>
        </xs:group>
      </xs:schema> })
    XSD

    scaffolds = ScaffoldParser.scaffold_to_string(schema)
    scaffold = Hash[scaffolds]['parsers/groups/configuration.rb']
    expect(scaffold).to eq(
      <<-CODE.chomp
module Parsers
  module Groups
    module Configuration
      def flag
        at 'flag'
      end

      def flag_attributes
        attributes_at 'flag'
      end

      def flag2
        at 'flag2'
      end

      def flag2_attributes
        attributes_at 'flag2'
      end

      def to_h
        hash = {}
        hash[:attributes] = attributes

        hash[:flag] = flag if has? 'flag'
        hash[:flag_attributes] = flag_attributes if has? 'flag'
        hash[:flag2] = flag2 if has? 'flag2'
        hash[:flag2_attributes] = flag2_attributes if has? 'flag2'

        hash
      end
    end
  end
end
      CODE
    )
  end

  let(:scaffolds) { scaffold_schema('./spec/groups/schema.xsd') }

  it 'scaffolds parser for type including group' do
    expect(scaffolds['parsers/order.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Order
    include ParserCore::BaseParser
    include Groups::Configuration

    def buyer
      submodel_at(Buyer, 'buyer')
    end

    def to_h
      hash = {}
      hash[:attributes] = attributes

      hash[:buyer] = buyer.to_h if has? 'buyer'

      mega.inject(hash) { |memo, r| memo.merge r }
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for type including group' do
    expect(scaffolds['parsers/buyer.rb']).to eq(
      <<-CODE.chomp
module Parsers
  class Buyer
    include ParserCore::BaseParser
    include Groups::Configuration

    def to_h
      hash = {}
      hash[:attributes] = attributes

      mega.inject(hash) { |memo, r| memo.merge r }
    end
  end
end
      CODE
    )
  end

  it 'scaffolds parser for group' do
    expect(scaffolds['parsers/groups/configuration.rb']).to eq(
      <<-CODE.chomp
module Parsers
  module Groups
    module Configuration
      def flag
        at 'flag'
      end

      def flag_attributes
        attributes_at 'flag'
      end

      def to_h
        hash = {}
        hash[:attributes] = attributes

        hash[:flag] = flag if has? 'flag'
        hash[:flag_attributes] = flag_attributes if has? 'flag'

        hash
      end
    end
  end
end
      CODE
    )
  end
end
