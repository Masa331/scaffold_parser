RSpec.describe 'complex types' do
  it 'parser scaffolder output matches template' do
    ScaffoldParser.scaffold('./spec/complex_types/schema.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/complex_types/order.rb')
    expect(File.read('tmp/currency.rb')).to eq File.read('spec/complex_types/currency.rb')
    expect(File.read('tmp/customer_type.rb')).to eq File.read('spec/complex_types/customer_type.rb')
  end
end
