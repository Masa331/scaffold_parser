RSpec.describe ScaffoldParser do
  it 'generates parser skeleton from given xsd' do
    ENV['XSD_PATH'] = './spec/fixtures/xsd/'

    ScaffoldParser.scaffold('./spec/fixtures/xsd/invoice.xsd')

    expect(File.read('./tmp/faktura_type.rb')).to eq File.read('./spec/fixtures/exemplar/faktura_type.rb')
    expect(File.read('./tmp/valuty.rb')).to eq File.read('./spec/fixtures/exemplar/valuty.rb')
    expect(File.read('./tmp/mena_type.rb')).to eq File.read('./spec/fixtures/exemplar/mena_type.rb')

    expect(File.exists?('./tmp/castka_type.rb')).to eq false
  end
end
