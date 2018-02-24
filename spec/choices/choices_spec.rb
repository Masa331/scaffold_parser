RSpec.describe ScaffoldParser do
  it 'choices are parsed correctly' do
    ScaffoldParser.scaffold('./spec/choices/choices.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/choices/order.rb')
  end
end
