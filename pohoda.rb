require 'ox'

require_relative 'tmp/mega'
require_relative 'string_with_attributes'
require_relative 'hash_with_attributes'
require_relative 'tmp/parsers/base_parser'
require_relative 'tmp/builders/base_builder'
require_relative 'tmp/parsers/inv/invoice_type'
require_relative 'tmp/builders/inv/invoice_type'

module Pohoda
  def self.parse(raw)
    parsed = Ox.load(raw, skip: :skip_none)
    content = parsed.locate('inv:invoice').first

    Pohoda::Parsers::Inv::InvoiceType.new(content)
  end

  def self.build(data, options = {})
    # Builders::MoneyData.new('MoneyData', data, options).to_xml

    Pohoda::Builders::Inv::InvoiceType.new('inv:invoice', data, options).to_xml
  end
end
# require_relative 'pohoda'; r = File.read('invoice.xml');i = Pohoda.parse r; i.to_h_with_attrs; r = Pohoda.build(i.to_h_with_attrs); File.open('./result.xml', 'wb') { |f| f.write r}
