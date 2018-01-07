require 'scaffold_parser/version'
require 'nokogiri'
require 'active_support/all'

module ScaffoldParser
  def self.scaffold(path)
    doc = Nokogiri::XML(File.open(path))
    xscaffold(doc, path)
  end

  def self.xscaffold(doc, path, class_name = nil)
    complex_types = doc.xpath('xs:schema/xs:complexType')

    complex_types.each do |complex_type|
      class_name = class_name || complex_type['name'].classify
      file_name = class_name.underscore << '.rb'

      methods = complex_type.xpath('xs:sequence/xs:element')
      methods = methods.map do |meth|
        template = method_template
        template.gsub!('NAME', meth['name'].underscore)

        if (type = meth['type'])
          if type.start_with?('xs:')
            template.gsub!('CONTENT', "at '#{meth['name']}'")
          else
            docs = collect_includes(doc, path)

            type_def = find_type(type, docs)

            if type_def.name == 'simpleType'
              template.gsub!('CONTENT', "at '#{meth['name']}'")
            else
              # require 'pry'; binding.pry
              #
              # fail 'WHOA I FOUND COMPLEX TYPE'

              class_name = meth['type'].classify
              xscaffold(type_def, path, class_name)

              template = "source = at '#{meth['name']}'\n\n#{class_name}.new(source) if source"
              template.gsub!('CONTENT', "at '#{meth['name']}'")
            end

            puts 'super!'
          end
        else
          if meth.xpath('xs:complexType').any?
            class_name = meth['name'].classify
            xscaffold(meth, path, class_name)

            template = "source = at '#{meth['name']}'\n\n#{class_name}.new(source) if source"
            template.gsub!('CONTENT', "at '#{meth['name']}'")
          else
            template.gsub!('CONTENT', "at '#{meth['name']}'")
          end
        end

        template
      end

      File.open(file_name, 'wb') do |f|
        class_definition = class_template.gsub('CLASS_NAME', class_name)
        class_definition.gsub!('METHODS', methods.join("\n"))

        f.puts class_definition
      end
    end
  end

  private

  def self.find_type(name, docs)
    doc = docs.find do |doc|
      doc.at_xpath("//*[@name='#{name}']").present?
    end

    if doc.blank?
      abort "Cant find element definition. Might be not enough includes?"
    end

    doc.at_xpath("//*[@name='#{name}']")
  end

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

  def self.class_template
    <<-TEMPLATE
module NAMESPACE
  class CLASS_NAME
    METHODS
  end
end
    TEMPLATE
  end

  def self.method_template
    <<-TEMPLATE
      def NAME
        CONTENT
      end
    TEMPLATE
  end
end
