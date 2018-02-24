require 'nokogiri'
require 'active_support/all'
require 'scaffold_parser/nokogiri_patches'
require 'scaffold_parser/file_patches'
require 'scaffold_parser/scaffolders/xsd'

Nokogiri::XML::Element.include ScaffoldParser::NokogiriPatches::Element
Nokogiri::XML::Document.include ScaffoldParser::NokogiriPatches::Document
File.include ScaffoldParser::FilePatches

module ScaffoldParser
  def self.scaffold(path, options = {})
    doc = Nokogiri::XML(File.open(path))

    Scaffolders::XSD.call(doc, options)
  end
end
