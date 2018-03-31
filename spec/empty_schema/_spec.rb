RSpec.describe 'simple types' do
  it 'parser scaffolder output matches template' do
    scaffolded_code = scaffold_schema('./spec/empty_schema/schema.xsd')

    expect(scaffolded_code).to eq({ a: 'lol' })
  end
end
