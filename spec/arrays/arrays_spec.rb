RSpec.describe ScaffoldParser do
  it 'arrayss are parsed correctly' do
    ScaffoldParser.scaffold('./spec/arrays/arrays.xsd')

    expect(File.read('tmp/order.rb')).to eq File.read('spec/arrays/order.rb')
    expect(File.read('tmp/payment_type.rb')).to eq File.read('spec/arrays/payment_type.rb')
    expect(File.read('tmp/payment.rb')).to eq File.read('spec/arrays/payment.rb')
    expect(File.read('tmp/messages.rb')).to eq File.read('spec/arrays/messages.rb')
    expect(File.read('tmp/recipient_type.rb')).to eq File.read('spec/arrays/recipient_type.rb')
  end
end
