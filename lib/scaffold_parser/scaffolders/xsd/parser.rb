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

          classes =
            xsds.map do |xsd|
              if @options[:verbose]
                puts "\n\nScaffolding schema which defines:"
                puts "#{xsd.children.map { |c| c.name }.compact}"
                puts
              end

              xsd.reverse_traverse do |element, children_result|
                handler =
                  if children_result.empty?
                    Handlers::Blank.new
                  elsif children_result.one?
                    children_result.first
                  else
                    #TODO: refactor. This is because of possible sequence inside of sequence
                    children = children_result.map do |child|
                      if child.is_a? Handlers::Elements
                        child.elements
                      else
                        child
                      end
                    end.flatten

                    #TODO: refactor. This shouldn't happen in fact. This is here only because of simple types right now
                    children.reject! { |child| child.is_a? Handlers::Blank }


                    Handlers::Elements.new(children)
                  end

                if @options[:verbose]
                  current_handler = handler.class.to_s.demodulize
                  childrens = children_result.map { |child| child.class.to_s.demodulize }
                  puts "#{current_handler}##{element.element_name} with #{element.attributes}, childrens are #{childrens}"
                end

                handler.send(element.element_name, element)
              end
            end

          classes = STACK.to_a
        end
      end
    end
  end
end
