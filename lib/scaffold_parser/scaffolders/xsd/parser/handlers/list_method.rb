module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
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

            def to_proxy_list(source, path)
              ProxyListMethod.new(source) do |m|
                m.at = [path] + @at
                m.item_class = @item_class
              end
            end

            def sequence(_)
              self
            end

            def choice(_)
              self
            end

            def all(_)
              self
            end

            def complex_type(source)
              if source.has_name?
                STACK.push Klass.new(source.name, [self])
              else
                self
              end
            end

            def element(source)
              if source.has_name?
                to_proxy_list(source, source.name)
              end
            end

            def extension(source)
              Extension.new(self, source.attributes)
            end
          end
        end
      end
    end
  end
end
