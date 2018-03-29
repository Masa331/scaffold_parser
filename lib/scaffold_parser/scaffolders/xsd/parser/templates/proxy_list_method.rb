module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class ProxyListMethod
            include BaseMethod
            include Utils

            attr_accessor :at, :item_class

            def initialize(source)
              @source = source
              yield self if block_given?
            end

            def method_body
              "array_of_at(#{item_class}, #{single_quote(at)})"
            end

            def to_h_with_attrs_method
              if item_class == 'String'
                "hash[:#{method_name}] = #{method_name} if has? '#{source.name}'"
              else
                "hash[:#{method_name}] = #{method_name}.map(&:to_h_with_attrs) if has? '#{source.name}'"
              end
            end

            def to_builder
              f = StringIO.new

              f.puts "if data.key? :#{method_name}"
              f.puts "  element = Ox::Element.new('#{at.first}')"
              if item_class == 'String'
                f.puts "  data[:#{method_name}].map { |i| Ox::Element.new('#{at.last}') << i }.each { |i| element << i }"
              else
                f.puts "  data[:#{method_name}].each { |i| element << #{item_class}.new('#{at.last}', i).builder }"
              end
              f.puts '  root << element'
              f.puts 'end'

              f.string.strip
            end

            def sequence(_)
              self
            end

            def complex_type(new_source)
              if new_source.has_name?
                template = Templates::Klass.new(new_source.name.camelize) do |template|
                  template.methods = [self]
                end
                STACK.push template

                Handlers::Blank.new
              else
                fail 'fok'
              end
            end
          end
        end
      end
    end
  end
end
