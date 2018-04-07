module ScaffoldParser
  module Templates
    class ListMethod
      include BaseMethod
      include Utils

      attr_accessor :at
      attr_reader :item_class

      def initialize(source)
        @source = source
        @at = [source.name]
        @item_class = source.has_custom_type? ? source&.type&.classify : 'String'
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
    end
  end
end
