require 'scaffold_parser/version'
require 'scaffold_parser/builder'
require 'nokogiri'
require 'active_support/all'
require 'scaffold_parser/nokogiri_patches'

Nokogiri::XML::Element.include ScaffoldParser::NokogiriPatches::Element
Nokogiri::XML::Document.include ScaffoldParser::NokogiriPatches::Document

module ScaffoldParser
  def self.scaffold(path, options = {})
    doc = Nokogiri::XML(File.open(path))

    Builder.call(doc, options)
  end
end
