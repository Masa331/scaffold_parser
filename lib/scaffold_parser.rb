require 'nokogiri'
require 'active_support/all'
require 'scaffold_parser/nokogiri_patches'
require 'scaffold_parser/file_patches'
require 'scaffold_parser/scaffolders/xsd'

Nokogiri::XML::Element.include ScaffoldParser::NokogiriPatches::Element
Nokogiri::XML::Document.include ScaffoldParser::NokogiriPatches::Document
StringIO.include ScaffoldParser::FilePatches

module ScaffoldParser
  def self.scaffold(path, options = {})
    unless Dir.exists?('./tmp/')
      Dir.mkdir('./tmp/')
      puts './tmp/ directory created'
    end

    unless Dir.exists?('./tmp/builders')
      Dir.mkdir('./tmp/builders')
      puts './tmp/builders directory created'
    end

    scaffold_to_string(path, options).each do |path, content|
      File.open(path, 'wb') { |f| f.write content }
    end
  end

  def self.scaffold_to_string(path, options = {})
    doc = Nokogiri::XML(File.open(path))

    Scaffolders::XSD.call(doc, options)
  end
end
