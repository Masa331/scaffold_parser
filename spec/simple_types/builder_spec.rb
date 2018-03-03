RSpec.describe 'simple types' do
  it 'builder scaffolder output matches template' do
    ScaffoldParser.scaffold('./spec/simple_types/schema.xsd')

    expect(File.read('tmp/builders/order.rb')).to eq File.read('spec/simple_types/order_builder.rb')
  end
end
