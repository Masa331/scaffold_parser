require 'xsd_model'

require 'active_support/all'
require 'scaffold_parser/file_patches'
require 'scaffold_parser/scaffolders/xsd'

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

    unless Dir.exists?('./tmp/parsers')
      Dir.mkdir('./tmp/parsers')
      puts './tmp/parsers directory created'
    end

    scaffold_to_string(path, options).each do |path, content|
      complete_path = path.prepend('./tmp/')

      puts "Writing out #{complete_path}" if options[:verbose]

      File.open(complete_path, 'wb') { |f| f.write content }
    end
  end

  def self.scaffold_to_string(path, options = {})
    # doc = XsdModel.parse(File.read(path))
    options = { collect_only: [:complex_type, :schema, :document, :element],
                skip_through: [:sequence, :schema] }
    doc = XsdModel.parse(File.read(path), options)
    # require 'pry'; binding.pry

    Scaffolders::XSD.call(doc, options)
  end
end
