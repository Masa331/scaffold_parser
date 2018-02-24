# All these tests should be rewritten to something actually readable from here.
# Could be useful: https://github.com/zverok/saharspec `eq_multiline(text)`
#
RSpec.describe ScaffoldParser do
  it 'generates parser skeleton from given xsd' do
    ScaffoldParser.scaffold('./invoice.xsd')

    expect(File.read('./tmp/faktura_type.rb')).to eq File.read('./spec/fixtures/exemplar/faktura_type.rb')
    expect(File.read('./tmp/valuty.rb')).to eq File.read('./spec/fixtures/exemplar/valuty.rb')
    expect(File.read('./tmp/mena_type.rb')).to eq File.read('./spec/fixtures/exemplar/mena_type.rb')
    expect(File.read('./tmp/pol_faktury_type.rb')).to eq File.read('./spec/fixtures/exemplar/pol_faktury_type.rb')
    expect(File.read('./tmp/pol_objedn_type.rb')).to eq File.read('./spec/fixtures/exemplar/pol_objedn_type.rb')
    expect(File.read('./tmp/souhrn_dph_type.rb')).to eq File.read('./spec/fixtures/exemplar/souhrn_dph_type.rb')
    expect(File.read('./tmp/dalsi_sazba.rb')).to eq File.read('./spec/fixtures/exemplar/dalsi_sazba.rb')
    expect(File.read('./tmp/uhrada_type.rb')).to eq File.read('./spec/fixtures/exemplar/uhrada_type.rb')
    expect(File.read('./tmp/dokl_ref_type.rb')).to eq File.read('./spec/fixtures/exemplar/dokl_ref_type.rb')
    expect(File.read('./tmp/doklad_hraz.rb')).to eq File.read('./spec/fixtures/exemplar/doklad_hraz.rb')
    expect(File.read('./tmp/neskl_polozka.rb')).to eq File.read('./spec/fixtures/exemplar/neskl_polozka.rb')

    expect(File.exists?('./tmp/castka_type.rb')).to eq false
    expect(File.exists?('./tmp/seznam_polozek.rb')).to eq false
    expect(File.exists?('./tmp/seznam_zal_polozek.rb')).to eq false
  end

  it 'outputs class in module if given' do
    ScaffoldParser.scaffold('./order.xsd', namespace: 'Something')

    expect(File.read('./tmp/order.rb')).to eq File.read('./spec/fixtures/exemplar/order.rb')
  end

  xit 'generates skeleton which has elements in root' do
    ScaffoldParser.scaffold('./_Document.xsd')

    expect(File.read('./tmp/money_data.rb')).to eq File.read('./spec/fixtures/exemplar/money_data.rb')
  end
end
