RSpec.describe 'simple types' do
  it 'parser scaffolder output matches template' do
    ScaffoldParser.scaffold('./spec/simple_types/schema.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/simple_types/order.rb')
  end
end
