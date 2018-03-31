module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        attr_reader :name, :node, :extension, :options

        def self.call(name, node, extension, options)
          self.new(name, node, extension, options).call
        end

        def initialize(name, node, extension, options)
          @name = name
          @node = node
          @extension = extension
          @options = options
        end

        def call
          template = ClassTemplate.new(name) do |template|
            template.requires = ['parsers/base_parser']

            methods = node.elements.map { |element| MethodFactory.call(element) }

            methods << MethodTemplate.new('to_h_with_attrs') do |template|
              body = "hash = HashWithAttributes.new({}, attributes)\n\n"

              node.elements.each do |element|
                if element.end_node?
                  body << "hash[:#{element.name.underscore}] = #{element.name.underscore} if has? '#{element.name}'"
                elsif element.submodel_node?
                  body << "hash[:#{element.name.underscore}] = #{element.name.underscore}.to_h_with_attrs if has? '#{element.name}'"
                end
                body << "\n"
              end

              body << "\n"
              body << 'hash'

              template.body = body
            end.to_s

            template.methods = methods
          end.to_s

          ["parsers/#{name.underscore}.rb", template.to_s]
        end
      end
    end
  end
end
