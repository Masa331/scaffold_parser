RSpec.describe ScaffoldParser do
  it 'simple types are parsed correctly' do
    ScaffoldParser.scaffold('./spec/simple_types/simple_type.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/simple_types/order.rb')
  end
end
