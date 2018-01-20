RSpec.describe ScaffoldParser do
  it 'generates parser skeleton from given xsd' do
    res = ScaffoldParser.scaffold('./spec/fixtures/xsd/invoice.xsd')
    # require 'pry'; binding.pry

    res
    # expect(File.read('./tmp/faktura_type.rb')).to eq File.read('./spec/fixtures/exemplar/faktura_type.rb')
  end

  it 'ble' do
    node = ScaffoldParser::Node.new
    node.name = 'Something'
    node2 = ScaffoldParser::Node.new
    node2.name = 'Anything'
    node3 = ScaffoldParser::Node.new
    node3.name = 'Everything'

    node4 = ScaffoldParser::Node.new
    node4.name = 'LOL'
    node3.nodes << node4

    root = ScaffoldParser::Node.new
    root.name = 'Root'
    root.nodes << node
    root.nodes << node2
    root.nodes << node3

    # require 'pry'; binding.pry
    puts root

    1
  end
end
