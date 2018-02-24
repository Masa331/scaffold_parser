RSpec.describe ScaffoldParser do
  it 'extensions are parsed correctly' do
    ScaffoldParser.scaffold('./spec/extensions/extensions.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/extensions/order.rb')
    expect(File.read('tmp/customer.rb')).to eq File.read('spec/extensions/customer.rb')
    expect(File.read('tmp/seller.rb')).to eq File.read('spec/extensions/seller.rb')
    expect(File.read('tmp/reference_type.rb')).to eq File.read('spec/extensions/reference_type.rb')
    expect(File.read('tmp/contact_info.rb')).to eq File.read('spec/extensions/contact_info.rb')
  end
end
