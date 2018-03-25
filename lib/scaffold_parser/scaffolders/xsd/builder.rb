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
          puts "Scaffolding builder for #{node.to_name}" if @options[:verbose]

          f = StringIO.new
          f.indent = true if @options[:namespace]

          f.puts "require '#{namespaced('builders/base_builder')}'"
          requires = node.submodel_nodes.map { |n| n.to_class_name.underscore }.uniq
          requires.each { |r| f.puts "require '#{namespaced(r.prepend('builders/'))}'" }
          requires = node.array_nodes.reject { |l| l.list_element.xs_type? }.uniq
          requires.each { |n| f.puts "require '#{namespaced(n.list_element.to_class_name.underscore.prepend('builders/'))}'" }
          f.puts

          f.puts "module #{@options[:namespace]}" if @options[:namespace]
          f.putsi "module Builders"
          f.putsi "  class #{node.to_class_name}"
          f.putsi "    include BaseBuilder"
          f.puts

          f.putsi "    def builder"
          f.putsi "      root = Ox::Element.new(name)"
          f.putsi "      if data.respond_to? :attributes"
          f.putsi "        data.attributes.each { |k, v| root[k] = v }"
          f.putsi "      end"

          f.puts if node.value_nodes.any?
          node.value_nodes.each do |node|
            f.putsi "      root << build_element('#{node.to_name}', data[:#{node.to_name.underscore}]) if data.key? :#{node.to_name.underscore}"
          end

          node.submodel_nodes.each do |node|
            f.puts
            f.putsi "      if data.key? :#{node.to_name.underscore}"
            f.putsi "        root << #{node.to_class_name}.new('#{node.to_name}', data[:#{node.to_name.underscore}]).builder"
            f.putsi "      end"
          end

          node.array_nodes.reject { |l| l.list_element.xs_type? }.each do |node|
            if node.named_list?
              f.puts
              f.putsi "      if data.key? :#{node.to_name.underscore}"
              f.putsi "        element = Ox::Element.new('#{node.to_name}')"
              f.putsi "        data[:#{node.to_name.underscore}].each { |i| element << #{node.list_element.to_class_name}.new('#{node.list_element.to_name}', i).builder }"
              f.putsi "        root << element"
              f.putsi "      end"
            else # simple_list
              f.puts
              f.putsi "      if data.key? :#{node.to_name.underscore}"
              f.putsi "        data[:#{node.to_name.underscore}].each { |i| root << #{node.list_element.to_class_name}.new('#{node.list_element.to_name}', i).builder }"
              f.putsi "      end"
            end
          end

          node.array_nodes.select { |l| l.list_element.xs_type? }.each do |node|
            f.puts

            if node.named_list?
              f.putsi "      if data.key? :#{node.to_name.underscore}"
              f.putsi "        element = Ox::Element.new('#{node.to_name}')"
              f.putsi "        data[:#{node.to_name.underscore}].map { |i| Ox::Element.new('#{node.list_element.to_name}') << i }.each { |i| element << i }"
              f.putsi "        root << element"
              f.putsi "      end"
            else #simple_list
              f.putsi "      if data.key? :#{node.to_name.underscore}"
              f.putsi "        data[:#{node.to_name.underscore}].map { |i| Ox::Element.new('#{node.to_name}') << i }.each { |i| root << i }"
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
