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

          classes =
            xsds.map do |xsd|
              # if @options[:verbose]
              #   puts "\n\nScaffolding schema which defines:\n#{xsd.children.map { |c| c.name }.compact}\n"
              # end

              xsd.reverse_traverse do |element, children_result|
                handler =
                  if children_result.empty?
                    Handlers::Blank.new
                  elsif children_result.one?
                    children_result.first
                  else
                    Handlers::Elements.new(children_result)
                  end

                if @options[:verbose] || true
                  current_handler = handler.class.to_s.demodulize
                  childrens = (handler.instance_variable_get('@elements') || []).map { |child| child.class.to_s.demodulize }
                  puts "#{current_handler}#{childrens}##{element.element_name}"
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
