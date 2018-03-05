module ScaffoldParser
  module Scaffolders
    class XSD
      class Builder
        attr_reader :node

        def self.call(node, options)
          self.new(node, options).call
        end

        def initialize(node, options)
          @node = node
          @options = options
        end

        def call
          f = StringIO.new
          f.indent = true if @options[:namespace]

          f.puts "require '#{namespaced('base_builder')}'"
          requires = node.submodel_nodes.map { |n| n.to_class_name.underscore }.uniq
          requires.each { |r| f.putsi "require '#{namespaced(r)}'" }
          requires = node.array_nodes.reject { |l| l.list_element.xs_type? }.uniq
          requires.each { |n| f.puts "require '#{namespaced(n.list_element.to_class_name.underscore)}'" }
          f.puts

          f.puts "module #{@options[:namespace]}" if @options[:namespace]
          f.putsi "module Builders"
          f.putsi "  class #{node.to_class_name}"
          f.putsi "    include BaseBuilder"
          f.puts

          accessors = node.value_nodes.map { |n| ":#{n.to_name.underscore}" }
          accessors += node.submodel_nodes.map { |n| ":#{n.to_name.underscore}" }
          accessors += node.array_nodes.map { |n| ":#{n.to_name.underscore}" }
          f.putsi "    attr_accessor #{accessors.join(', ')}"
          f.puts

          f.putsi "    def builder"
          f.putsi "      root = Ox::Element.new(element_name)"

          f.puts if node.value_nodes.any? || node.submodel_nodes.any?
          node.value_nodes.each do |node|
            f.putsi "      root << Ox::Element.new('#{node.to_name}') << #{node.to_name.underscore} if #{node.to_name.underscore}"
          end

          node.submodel_nodes.each do |node|
            f.putsi "      root << #{node.to_class_name}.new(#{node.to_name.underscore}, '#{node.to_name}').builder if #{node.to_name.underscore}"
          end

          node.array_nodes.reject { |l| l.list_element.xs_type? }.each do |node|
            if node.named_list?
              f.puts
              f.putsi "      if #{node.to_name.underscore}"
              f.putsi "        element = Ox::Element.new('#{node.to_name}')"
              f.putsi "        #{node.to_name.underscore}.each { |i| element << #{node.list_element.to_class_name}.new(i, '#{node.list_element.to_name}').builder }"
              f.putsi "        root << element"
              f.putsi "      end"
            else # simple_list
              f.puts
              f.putsi "      if #{node.to_name.underscore}"
              f.putsi "        #{node.to_name.underscore}.each { |i| root << #{node.list_element.to_class_name}.new(i, '#{node.list_element.to_name}').builder }"
              f.putsi "      end"
            end
          end

          node.array_nodes.select { |l| l.list_element.xs_type? }.each do |node|
            f.puts

            if node.named_list?
              f.putsi "      if #{node.to_name.underscore}"
              f.putsi "        element = Ox::Element.new('#{node.to_name}')"
              f.putsi "        #{node.to_name.underscore}.map { |i| Ox::Element.new('#{node.list_element.to_name}') << i }.each { |i| element << i }"
              f.putsi "        root << element"
              f.putsi "      end"
            else #simple_list
              f.putsi "      if #{node.to_name.underscore}"
              f.putsi "        #{node.to_name.underscore}.map { |i| Ox::Element.new('#{node.to_name}') << i }.each { |i| root << i }"
              f.putsi "      end"
            end
          end

          f.puts
          f.putsi "      root"
          f.putsi "    end"


          f.putsi "  end"
          f.putsi "end"
          f.puts "end" if @options[:namespace]

          ["builders/#{node.to_class_name.underscore}.rb", f.string.strip]
        end

        private

        def namespaced(path)
          [@options[:namespace]&.underscore, path].compact.join('/')
        end
      end
    end
  end
end
