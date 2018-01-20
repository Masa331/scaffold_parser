require 'scaffold_parser/version'
require 'scaffold_parser/modeler'
require 'scaffold_parser/builder'
require 'scaffold_parser/node'
require 'nokogiri'
require 'active_support/all'

require 'scaffold_parser/types'
require 'scaffold_parser/type_class_resolver'

module ScaffoldParser
  def self.scaffold(path)
    doc = Nokogiri::XML(File.open(path))

    includes = collect_includes(doc, path)

    model = Modeler.call(doc, includes)

    Builder.call(model)
  end

  private

  def self.collect_includes(doc, original_path)
    includes = doc.xpath('//xs:include').map { |incl| incl['schemaLocation'] }

    docs = [doc] + includes.map do |include_path|
      dir = original_path.split('/')
      include_path = (dir[0..-2] + [include_path]).join('/')
      Nokogiri::XML(File.open(include_path))
    end

    second_lvl_includes = docs.flat_map { |d| d.xpath('//xs:include').map { |incl| incl['schemaLocation'] } }
    second_lvl_includes = second_lvl_includes.uniq
    second_lvl_includes = second_lvl_includes - includes

    second_lvl_docs = second_lvl_includes.map do |include_path|
      dir = original_path.split('/')
      include_path = (dir[0..-2] + [include_path]).join('/')
      Nokogiri::XML(File.open(include_path))
    end

    docs + second_lvl_docs
  end
end
