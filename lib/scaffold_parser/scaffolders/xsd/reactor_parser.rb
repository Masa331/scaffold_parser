require 'scaffold_parser/scaffolders/xsd/reactor_parser/handlers/base_handler'

handlers_dir = Dir.pwd + '/lib/scaffold_parser/scaffolders/xsd/reactor_parser/handlers/'
entries = Dir.entries(handlers_dir).map { |h| h.gsub('.rb', '') }
entries.delete '.'
entries.delete '..'
handlers = entries.map { |h| h.gsub('.rb', '').prepend handlers_dir }

handlers.each do |h|
  require h
end


module XsdModel
  module Elements
    module BaseElement
      XSD_URI = 'http://www.w3.org/2001/XMLSchema'

      def xsd_prefix
        namespaces.invert[XSD_URI].gsub('xmlns:', '')
      end
    end
  end
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
            @current_handler = current_handler.send child.element_name
          end

          current_handler.complete.map do |class_template|
            ['parsers/order.rb', class_template]
          end
        end
      end
    end
  end
end
