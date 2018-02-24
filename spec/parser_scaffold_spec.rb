RSpec.describe ScaffoldParser do
  it 'outputs class in module if given' do
    ScaffoldParser.scaffold('./order.xsd', namespace: 'Something')

    expect(File.read('./tmp/order.rb')).to eq File.read('./spec/fixtures/exemplar/order.rb')
  end
end
