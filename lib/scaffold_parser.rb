require 'xsd_model'
require 'fileutils'
require 'active_support/all'
require 'scaffold_parser/scaffolders/xsd'

module XsdModel
  module Elements
    module BaseElement
      def xmlns_prefix
        nil if xmlns_uri.nil?

        ary = namespaces.to_a

        candidates = ary.select do |n|
          n[1] == xmlns_uri
        end.map(&:first)

        full_prefix = candidates.find do |c|
          c.start_with? 'xmlns:'
        end

        full_prefix&.gsub('xmlns:', '')
      end

      def xmlns_uri
        namespaces['xmlns']
      end

      def name_with_prefix
        [xmlns_prefix, name].compact.join(':')
      end

      def type_with_prefix
        if type&.include? ':'
          type
        else
          [xmlns_prefix, type].compact.join(':')
        end
      end
    end

    class Element
      def has_ref?
        !ref.nil?
      end

      def ref
        attributes['ref']
      end
    end
  end
end

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
