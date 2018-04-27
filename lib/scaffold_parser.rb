require 'xsd_model'
require 'active_support/all'
require 'scaffold_parser/scaffolders/xsd'

module ScaffoldParser
  def self.scaffold(path, options = {})
    ensure_dir_exists('./tmp/')
    ensure_dir_exists('./tmp/builders')
    ensure_dir_exists('./tmp/builders/groups')
    ensure_dir_exists('./tmp/parsers')
    ensure_dir_exists('./tmp/parsers/groups')

    scaffold_to_string(File.read(path), options).each do |path, content|
      complete_path = path.prepend('./tmp/')

      puts "Writing out #{complete_path}" if options[:verbose]

      File.open(complete_path, 'wb') { |f| f.write content }
    end
  end

  def self.scaffold_to_string(schema, options = {})
    parse_options = { collect_only: [:element,
                                     :complex_type,
                                     :sequence,
                                     :all,
                                     :choice,
                                     :schema,
                                     :include,
                                     :import,
                                     :group,
                                     :extension] }
    doc = XsdModel.parse(schema, parse_options)

    Scaffolders::XSD.call(doc, options, parse_options)
  end

  private

  def self.ensure_dir_exists(path)
    unless Dir.exists?(path)
      Dir.mkdir(path)
      puts "#{path} directory created"
    end
  end
end
