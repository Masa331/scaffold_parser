require 'scaffold_parser/scaffolders/xsd/parser/stack'
require 'scaffold_parser/scaffolders/xsd/parser/array_refinement'

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
        using ArrayRefinement

        attr_reader :xsd

        def self.call(xsd, options)
          self.new(xsd, options).call
        end

        def initialize(xsd, options)
          @xsd = xsd
          @options = options
        end

        STACK = Stack.instance

        def call
          STACK.clear

          classes = xsd.reverse_traverse do |element, children_result|
            # current_handler = children_result.handler.class.to_s.demodulize
            # childrens = children_result.map { |child| child.class.to_s.demodulize }
            # puts "#{current_handler}##{element.element_name} with #{element.attributes}, childrens are #{childrens}"

            children_result.handler.send(element.element_name, element)
          end.to_a

          classes
        end
      end
    end
  end
end
