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

        attr_reader :xsds

        def self.call(xsds)
          self.new(xsds).call
        end

        def initialize(xsds)
          @xsds = xsds
        end

        STACK = Stack.instance

        def call
          STACK.clear

          classes =
            xsds.map do |xsd|
              xsd.reverse_traverse do |element, children_result|
                handler =
                  if children_result.empty?
                    Handlers::Blank.new
                  elsif children_result.one?
                    children_result.first
                  else
                    Handlers::Elements.new(children_result)
                  end

                # current_handler = handler.class.to_s.demodulize
                # childrens = children_result.map { |child| child.class.to_s.demodulize }
                # puts "#{current_handler}##{element.element_name} with #{element.attributes}, childrens are #{childrens}"

                handler.send(element.element_name, element)
              end
            end

          classes = STACK.to_a
        end
      end
    end
  end
end
