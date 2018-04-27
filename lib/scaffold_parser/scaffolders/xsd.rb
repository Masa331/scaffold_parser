require 'scaffold_parser/scaffolders/xsd/parser'
require 'scaffold_parser/scaffolders/xsd/parser/handlers/utils'

module ScaffoldParser
  module Scaffolders
    class XSD
      include Parser::Handlers::Utils

      def self.call(doc, options, parse_options = {})
        self.new(doc, options, parse_options).call
      end

      def initialize(doc, options, parse_options = {})
        @doc = doc
        @options = options
        @parse_options = parse_options
      end

      def call
        all = [@doc.schema] + @doc.schema.collect_included_schemas(@parse_options) + @doc.schema.collect_imported_schemas(@parse_options)

        classes = Parser.call(all, @options)
        top_level_elements = all.flat_map(&:elements)
        ref_map = top_level_elements.map { |e| [e.name_with_prefix, e.type_with_prefix]}.to_h

        # reject dumb classes which are just extension proxies to simple types :D
        classes = classes.reject do |klass|
          inherit_from = classes.find do |cl|
            cl.name_with_prefix == klass&.inherit_from&.split(':')&.map(&:camelize)&.join('::')
          end

          klass.methods.empty? && klass.includes.empty? && inherit_from.nil?
        end

        # remove dumb classes inheritance
        classes = classes.map do |klass|
          inherit_from = classes.find do |cl|
            cl.name_with_prefix == klass&.inherit_from&.split(':')&.map(&:camelize)&.join('::')
          end

          if inherit_from.nil?
            klass.inherit_from = nil
          end
          klass
        end

        # remove dumb classes includes
        classes = classes.map do |klass|
          existing_includes = (klass.includes || []).select do |incl|
            classes.map(&:name_with_prefix).include? incl.full_ref
          end

          klass.includes = existing_includes

          klass
        end

        # remove proxy lists through named complex types
        # #TODO: could i somehow remove proxy complex types so they are not outputted into class files?
        #   ... they are not used anyhow.. probably not used..? Can't they be inherited from or something?
        classes = classes.map do |klass|
          klass.methods = klass.methods.map do |meth|
            if meth.is_a?(Parser::Handlers::SubmodelMethod)
              submodel_class = classes.find { |cl| cl.name_with_prefix == meth.submodel_class }

              if (submodel_class.methods.size == 1) && submodel_class.methods.first.is_a?(Parser::Handlers::ListMethod) && submodel_class.inherit_from.nil? && submodel_class.includes.empty?
                submodel_class.methods.first.to_proxy_list(meth.source, meth.at)
              else
                meth
              end
            else
              meth
            end
          end

          klass
        end

        classes.each do |klass|
          klass.methods = klass.methods.map do |meth|
            if meth.is_a?(Parser::Handlers::SubmodelMethod) && !classes.map(&:name_with_prefix).include?(meth.submodel_class)
              meth.to_at_method
            elsif  meth.is_a?(Parser::Handlers::ElementRef)
              meth.to_submodel_method(ref_map)
            else
              meth
            end
          end
        end

        requires = create_requires_template(classes)
        parsers = classes.map do |klass|
          path = ["parsers", klass.namespace&.underscore, "#{klass.name.underscore}.rb"].compact.join('/')
          string = wrap_in_namespace(klass.to_s, 'Parsers')

          [path, string]
        end
        builders = classes.map do |klass|
          path = ["builders", klass.namespace&.underscore, "#{klass.name.underscore}.rb"].compact.join('/')
          string = wrap_in_namespace(klass.to_builder_s, 'Builders')

          [path, string]
        end

        all = parsers + builders
        result = all.map do |path, string|
          [path, wrap_in_namespace(string, @options[:namespace])]
        end

        result + [['requires.rb', requires]]
      end

      private

      def create_requires_template(classes)
        modules = classes.select { |cl| cl.is_a? Parser::Handlers::Module }
        classes = classes.select { |cl| cl.is_a? Parser::Handlers::Klass }
        with_inheritance, others = classes.partition { |klass| klass.inherit_from }

        requires = []
        modules.each do |klass|
          requires << ["parsers", klass.namespace&.underscore, klass.name.underscore].compact.join('/')
          requires << ["builders", klass.namespace&.underscore, klass.name.underscore].compact.join('/')
        end
        others.each do |klass|
          requires << ["parsers", klass.namespace&.underscore, klass.name.underscore].compact.join('/')
          requires << ["builders", klass.namespace&.underscore, klass.name.underscore].compact.join('/')
        end
        with_inheritance.each do |klass|
          requires << ["parsers", klass.namespace&.underscore, klass.name.underscore].compact.join('/')
          requires << ["builders", klass.namespace&.underscore, klass.name.underscore].compact.join('/')
        end

        if @options[:namespace]
          requires = requires.map { |r| r.prepend("#{@options[:namespace].underscore}/") }
        end

        requires.map { |r| "require '#{r}'" }.join("\n")
      end
    end
  end
end
