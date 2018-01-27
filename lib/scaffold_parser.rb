require 'scaffold_parser/version'
require 'scaffold_parser/modeler'
require 'scaffold_parser/builder'
require 'scaffold_parser/node'
require 'nokogiri'
require 'active_support/all'

require 'scaffold_parser/types'
# require 'scaffold_parser/type_class_resolver'

require 'scaffold_parser/nokogiri_patches'

Nokogiri::XML::Element.include ScaffoldParser::NokogiriPatches::Element
Nokogiri::XML::Document.include ScaffoldParser::NokogiriPatches::Document

module ScaffoldParser
  def self.scaffold(path)
    doc = Nokogiri::XML(File.open(path))

    Builder.call(doc)
  end
end
