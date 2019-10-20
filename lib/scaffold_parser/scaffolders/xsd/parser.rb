require 'scaffold_parser/scaffolders/xsd/parser/stack'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/requires'

module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        attr_reader :xsds

        def self.call(xsds, options)
          self.new(xsds, options).call
        end

        def initialize(xsds, options)
          @xsds = xsds
          @options = options
        end

        STACK = Stack.instance

        def call
          STACK.clear

          xsds.each do |xsd|
            xsd.reverse_traverse do |element, children_result|
              handler =
                if children_result.empty?
                  Handlers::Blank.new
                elsif children_result.one?
                  children_result.first
                else
                  Handlers::Elements.new(children_result)
                end

              handler.send(element.element_name, element)
            rescue
              p "Something happened during processing schema #{xsd.source} and node #{element.css_path}"
              raise
            end
          end

          STACK.to_a
        end
      end
    end
  end
end
