require 'scaffold_parser/scaffolders/xsd/parser/stack'
require 'scaffold_parser/scaffolders/xsd/parser/array_refinement'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/base'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/blank'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/sequence'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/complex_type'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/element'

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
            # wip = children_result.handler.wip.class.to_s.demodulize
            # puts "Current handler: #{current_handler}, calling #{element.element_name} with #{element.attributes}, wip is #{wip}"

            children_result.handler.send(element.element_name, element)
          end.to_a
        end
      end
    end
  end
end
