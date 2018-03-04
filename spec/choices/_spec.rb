RSpec.describe 'choices' do
  it 'parser scaffolder matches template' do
    ScaffoldParser.scaffold('./spec/choices/schema.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/choices/order.rb')
  end

  it 'builder scaffolder matches template' do
    ScaffoldParser.scaffold('./spec/choices/schema.xsd')

    expect(File.read('tmp/builders/order.rb')).to eq File.read('spec/choices/order_builder.rb')
  end
end
