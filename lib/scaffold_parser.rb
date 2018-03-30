require 'xsd_model'

require 'active_support/all'

require 'scaffold_parser/template_utils'
require 'scaffold_parser/class_template'
require 'scaffold_parser/method_template'
require 'scaffold_parser/method_factory'

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
    collect_only = -> (e) { ['schema', 'document', 'element', 'extension', 'complexType'].include?(e.name) }
    ignore = -> (e) { e.name == 'complexType' && e['name'].nil? }
    doc = XsdModel.parse(File.read(path), { collect_only: collect_only, ignore: ignore })

    Scaffolders::XSD.call(doc, options)
  end
end
