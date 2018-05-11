require 'xsd_model'
require 'fileutils'
require 'active_support/all'
require 'scaffold_parser/scaffolders/xsd'

module ScaffoldParser
  def self.scaffold(path, options = {})
    scaffold_to_string(File.read(path), options).each do |path, content|
      complete_path = path.prepend('./tmp/')
      ensure_dir_exists(complete_path, options)

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

  def self.ensure_dir_exists(path, options)
    dir = path.split('/')[0..-2].join('/')

    unless Dir.exists?(dir)
      FileUtils.mkdir_p(dir)

      puts "#{dir} directory created" if options[:verbose]
    end
  end
end
