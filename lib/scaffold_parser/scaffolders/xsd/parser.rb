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
          path = "./tmp/#{node.to_file_name}.rb"

          File.open(path, 'wb') do |f|
            f.indent = true if @options[:namespace]

            f.puts "require '#{namespaced('base_element')}'"
            node.parent_nodes.each { |n| f.puts "require '#{namespaced(n.to_require)}'" }
            node.list_nodes.reject { |l| l.list_element.xs_type? }.each { |n| f.puts "require '#{namespaced(n.to_require)}'" }
            f.puts

            f.puts "module #{@options[:namespace]}" if @options[:namespace]
            f.putsi "class #{node.to_class_name}"
            f.putsi "  include BaseElement"

            node.end_nodes.each do |method|
              f.puts

              method_name = method.to_method_name
              at = method.to_location

              f.putsi "  def #{method_name}"
              f.putsi "    at :#{at}"
              f.putsi "  end"
            end

            node.parent_nodes.each do |method|
              f.puts

              klass = method.to_class_name
              method_name = method.to_method_name
              at = method.to_location

              f.putsi "  def #{method_name}"
              f.putsi "    submodel_at(#{klass}, :#{at})"
              f.putsi "  end"
            end

            node.list_nodes.reject { |l| l.list_element.xs_type? }.each do |method|
              f.puts

              list_element_klass = method.list_element_klass
              method_name = method.to_method_name
              list_element_at = method.list_element_at.map { |e| ":#{e}" }.join(', ')

              f.putsi "  def #{method_name}"
              f.putsi "    array_of_at(#{list_element_klass}, [#{list_element_at}])"
              f.putsi "  end"
            end

            node.list_nodes.select { |l| l.list_element.xs_type? }.each do |method|
              f.puts

              list_element_klass = method.list_element_klass
              method_name = method.to_method_name
              list_element_at = method.list_element_at.map { |e| ":#{e}" }.join(', ')

              f.putsi "  def #{method_name}"
              f.putsi "    array_of_at(String, [#{list_element_at}])"
              f.putsi "  end"
            end

            ### to_h method
            lines = []
            node.end_nodes.each do |node|
              lines << "#{node.to_method_name}: #{node.to_method_name},"
            end
            node.parent_nodes.each do |node|
              lines << "#{node.to_method_name}: #{node.to_method_name}.to_h,"
            end
            node.list_nodes.reject { |l| l.list_element.xs_type? }.each do |node|
              lines << "#{node.to_method_name}: #{node.to_method_name}.map(&:to_h),"
            end
            node.list_nodes.select { |l| l.list_element.xs_type? }.each do |node|
              lines << "#{node.to_method_name}: #{node.to_method_name},"
            end
            if lines.any?
              f.puts
              lines.last.chop!
              first_line = lines.shift

              f.putsi "  def to_h"
              f.putsi "    { #{first_line}"
              lines.each do |line|
                f.putsi "      #{line}"
              end
              f.putsi "    }.delete_if { |k, v| v.nil? || v.empty? }"
              f.putsi "  end"
            end
            f.putsi "end"
            f.puts "end" if @options[:namespace]
          end
        end

        private

        def namespaced(path)
          [@options[:namespace]&.underscore, path].compact.join('/')
        end
      end
    end
  end
end
