require 'scaffold_parser/scaffolders/xsd/reactor_parser/handlers/base_handler'

handlers_dir = Dir.pwd + '/lib/scaffold_parser/scaffolders/xsd/reactor_parser/handlers/'
entries = Dir.entries(handlers_dir).map { |h| h.gsub('.rb', '') }
entries.delete '.'
entries.delete '..'
handlers = entries.map { |h| h.gsub('.rb', '').prepend handlers_dir }

handlers.each do |h|
  require h
end

module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        attr_reader :xsd, :current_handler

        def self.call(xsd, options)
          self.new(xsd, options).call
        end

        def initialize(xsd, options)
          @xsd = xsd
          @options = options
          @current_handler = Handlers::XSD.new nil
        end

        def call
          after_children_hook = Proc.new { @current_handler = current_handler.complete }

          xsd.traverse(after_children_hook) do |child|
            @current_handler = current_handler.handle child
          end

          current_handler.products.map do |class_template|
            ["parsers/#{class_template.name.underscore}.rb", class_template.to_s]
          end
        end
      end
    end
  end
end
