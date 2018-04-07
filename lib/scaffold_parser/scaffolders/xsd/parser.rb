require 'scaffold_parser/scaffolders/xsd/parser/stack'

require 'scaffold_parser/scaffolders/xsd/parser/handlers/base'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/blank'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/choice'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/complex_content'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/complex_type'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/element'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/elements'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/extension'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/max_length'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/restriction'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/schema'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/sequence'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/simple_content'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/simple_type'

require 'scaffold_parser/scaffolders/xsd/parser/templates/all'

module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser

        attr_reader :xsd

        def self.call(xsd)
          self.new(xsd).call
        end

        def initialize(xsd)
          @xsd = xsd
        end

        STACK = Stack.instance

        def call
          STACK.clear

          classes = xsd.reverse_traverse do |element, children_result|
            handler =
              if children_result.empty?
                Handlers::Blank.new
              elsif children_result.one?
                children_result.first
              else
                Handlers::Elements.new(children_result)
              end

            handler.send(element.element_name, element)
          end.to_a

          classes
        end
      end
    end
  end
end
