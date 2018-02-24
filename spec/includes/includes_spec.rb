RSpec.describe ScaffoldParser do
  it 'includes are parsed correctly' do
    ScaffoldParser.scaffold('./spec/includes/includes.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/includes/order.rb')
  end
end
