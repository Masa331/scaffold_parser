module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class ListMethod
            include BaseMethod
            include Utils

            attr_accessor :at, :item_class

            def initialize(source)
              @source = source
              @at = [source.name]
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
              if item_class == 'String'
                f.puts "  data[:#{method_name}].map { |i| Ox::Element.new('#{at.first}') << i }.each { |i| root << i }"
              else
                f.puts "  data[:#{method_name}].each { |i| root << #{item_class}.new('#{at.first}', i).builder }"
              end
              f.puts 'end'

              f.string.strip
            end

            def to_proxy_list(new_source, path)
              ProxyListMethod.new(new_source) do |m|
                m.at = [path] + @at
                m.item_class = @item_class
              end
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
                self
              end
            end

            def element(new_source)
              if new_source.has_name?
                to_proxy_list(new_source, new_source.name)
              else
                fail 'fok'
              end
            end

            def extension(new_source)
              template = Templates::Klass.new do |template|
                template.methods = [self]
                template.inherit_from = new_source.base.camelize
              end

              template
            end
          end
        end
      end
    end
  end
end
