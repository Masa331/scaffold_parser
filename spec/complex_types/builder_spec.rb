RSpec.describe 'complex types' do
  it 'builder scaffolder output matches template' do
    ScaffoldParser.scaffold('./spec/complex_types/schema.xsd')

    expect(File.read('tmp/builders/order.rb')).to eq File.read('spec/complex_types/order_builder.rb')
    expect(File.read('tmp/builders/currency.rb')).to eq File.read('spec/complex_types/currency_builder.rb')
    expect(File.read('tmp/builders/customer_type.rb')).to eq File.read('spec/complex_types/customer_type_builder.rb')
  end
end
