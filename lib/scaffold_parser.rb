require 'xsd_model'
require 'active_support/all'
require 'scaffold_parser/scaffolders/xsd'

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

    unless Dir.exists?('./tmp/builders/groups')
      Dir.mkdir('./tmp/builders/groups')
      puts './tmp/builders directory created'
    end

    unless Dir.exists?('./tmp/parsers')
      Dir.mkdir('./tmp/parsers')
      puts './tmp/parsers directory created'
    end

    unless Dir.exists?('./tmp/parsers/groups')
      Dir.mkdir('./tmp/parsers/groups')
      puts './tmp/parsers directory created'
    end

    scaffold_to_string(File.read(path), options).each do |path, content|
      complete_path = path.prepend('./tmp/')

      puts "Writing out #{complete_path}" if options[:verbose]

      File.open(complete_path, 'wb') { |f| f.write content }
    end
  end

  def self.scaffold_to_string(schema, options = {})
    parse_options = { ignore: [:annotation,
                               :text,
                               :comment,
                               :documentation,
                               :attribute,
                               :length,
                               :enumeration,
                               :appinfo,
                               :pattern,
                               :total_digits, :fraction_digits, :white_space, :min_exclusive, :collection,
                               :schema_info, :doctype, :logical, :content, :min_length, :min_inclusive, :max_inclusive, :union, :attribute_group
    ] }
    doc = XsdModel.parse(schema, parse_options)

    Scaffolders::XSD.call(doc, options, parse_options)
  end
end
