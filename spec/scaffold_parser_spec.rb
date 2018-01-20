RSpec.describe ScaffoldParser do
  it 'generates parser skeleton from given xsd' do
    ScaffoldParser.scaffold('./spec/fixtures/xsd/invoice.xsd')

    expect(File.read('./tmp/faktura_type.rb')).to eq File.read('./spec/fixtures/exemplar/faktura_type.rb')
  end
end
