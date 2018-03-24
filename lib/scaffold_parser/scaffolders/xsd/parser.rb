module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        attr_reader :node

        def self.call(node, options)
          self.new(node, options).call
        end

        def initialize(node, options)
          @node = node
          @options = options
        end

        def call
          puts "Scaffolding parser for #{node.to_name}" if @options[:verbose]

          f = StringIO.new
          f.indent = true if @options[:namespace]

          f.puts "require '#{namespaced('parsers/base_parser')}'"
          node.submodel_nodes.map { |n| namespaced(n.to_class_name.underscore.prepend('parsers/')) }.uniq.each { |n| f.puts "require '#{n}'" }
          node.array_nodes.reject { |l| l.list_element.xs_type? }.each { |n| f.puts "require '#{namespaced(n.list_element.to_class_name.underscore.prepend('parsers/'))}'" }
          f.puts

          f.puts "module #{@options[:namespace]}" if @options[:namespace]
          f.putsi "module Parsers"
          f.putsi "  class #{node.to_class_name}"
          f.putsi "    include BaseParser"

          node.value_nodes.each do |method|
            f.puts

            method_name = method.to_name.underscore
            at = method.to_name

            f.putsi "    def #{method_name}"
            f.putsi "      at :#{at}"
            f.putsi "    end"
          end

          node.submodel_nodes.each do |method|
            f.puts

            klass = method.to_class_name
            method_name = method.to_name.underscore
            at = method.to_name

            f.putsi "    def #{method_name}"
            f.putsi "      submodel_at(#{klass}, :#{at})"
            f.putsi "    end"
          end

          node.array_nodes.reject { |l| l.list_element.xs_type? }.each do |method|
            f.puts

            list_element_klass = method.list_element_klass
            method_name = method.to_name.underscore
            list_element_at = method.list_element_at.map { |e| ":#{e}" }.join(', ')

            f.putsi "    def #{method_name}"
            f.putsi "      array_of_at(#{list_element_klass}, [#{list_element_at}])"
            f.putsi "    end"
          end

          node.array_nodes.select { |l| l.list_element.xs_type? }.each do |method|
            f.puts

            list_element_klass = method.list_element_klass
            method_name = method.to_name.underscore
            list_element_at = method.list_element_at.map { |e| ":#{e}" }.join(', ')

            f.putsi "    def #{method_name}"
            f.putsi "      array_of_at(String, [#{list_element_at}])"
            f.putsi "    end"
          end

          ### to_h method
          lines = []
          node.value_nodes.each do |node|
            lines << "hash[:#{node.to_name.underscore}] = #{node.to_name.underscore} if raw.key? :#{node.to_name}"
          end

          node.submodel_nodes.each do |node|
            lines << "hash[:#{node.to_name.underscore}] = #{node.to_name.underscore}.to_h if raw.key? :#{node.to_name}"
          end
          node.array_nodes.reject { |l| l.list_element.xs_type? }.each do |node|
            lines << "hash[:#{node.to_name.underscore}] = #{node.to_name.underscore}.map(&:to_h) if raw.key? :#{node.to_name}"
          end
          node.array_nodes.select { |l| l.list_element.xs_type? }.each do |node|
            lines << "hash[:#{node.to_name.underscore}] = #{node.to_name.underscore} if raw.key? :#{node.to_name}"
          end
          if lines.any?
            f.puts
            # lines.last.chop!
            # first_line = lines.shift

            f.putsi "    def to_h"
            f.putsi "      hash = {}"
            f.puts

            lines.each do |line|
              f.putsi "      #{line}"
            end
            f.puts

            f.putsi "      hash"
            f.putsi "    end"
          end
          f.putsi "  end"
          f.putsi "end"
          f.puts "end" if @options[:namespace]

          ["parsers/#{node.to_class_name.underscore}.rb", f.string.strip]
        end

        private

        def namespaced(path)
          [@options[:namespace]&.underscore, path].compact.join('/')
        end
      end
    end
  end
end
