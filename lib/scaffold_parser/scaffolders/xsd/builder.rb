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
          f.puts

          f.puts "module #{@options[:namespace]}" if @options[:namespace]
          f.putsi "module Builders"
          f.putsi "  class #{node.to_class_name}"
          f.putsi "    include BaseBuilder"
          f.puts

          accessors = node.value_nodes.map { |n| ":#{n.to_name.underscore}" }
          accessors += node.submodel_nodes.map { |n| ":#{n.to_name.underscore}" }

          f.putsi "    attr_accessor #{accessors.join(', ')}"
          f.puts

          f.putsi "    def builder"
          f.putsi "      root = Ox::Element.new('#{node.to_name}')"
          f.puts

          node.value_nodes.each do |node|
            f.putsi "      root << Ox::Element.new('#{node.to_name}') << #{node.to_name.underscore} if #{node.to_name.underscore}"
          end

          node.submodel_nodes.each do |node|
            f.putsi "      root << #{node.to_class_name}.new(#{node.to_name.underscore}).builder if #{node.to_name.underscore}"
          end

          f.puts
          f.putsi "      root"
          f.putsi "    end"


          f.putsi "  end"
          f.putsi "end"
          f.puts "end" if @options[:namespace]

          ["builders/#{node.to_class_name.underscore}.rb", f.string]
        end

        private

        def namespaced(path)
          [@options[:namespace]&.underscore, path].compact.join('/')
        end
      end
    end
  end
end
