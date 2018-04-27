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

        classes.each do |klass|
          klass.methods = klass.methods.map do |meth|
            if meth.is_a?(Parser::Handlers::SubmodelMethod) && !classes.map(&:name).include?(meth.submodel_class)
              meth.to_at_method
            else
              meth
            end
          end
        end

        classes.each do |klass|
          klass.namespace = @options[:namespace]
        end

        classes.flat_map do |class_template|
          [["parsers/#{class_template.name.underscore}.rb", class_template.to_s],
           ["builders/#{class_template.name.underscore}.rb", class_template.to_builder_s],
           ["parsers/base_parser.rb", wrap_in_namespace(base_parser_template, @options[:namespace])],
           ["builders/base_builder.rb", wrap_in_namespace(base_builder_template, @options[:namespace])],
           ["requires.rb", create_requires_template(classes)],
           ["hash_with_attrs.rb", wrap_in_namespace(hash_with_attrs_template, @options[:namespace])],
           ["mega.rb", wrap_in_namespace(mega_template, @options[:namespace])]
          ]
        end
      end

      private

      def base_parser_template
        <<~TEMPLATE
          module Parsers
            module BaseParser
              include Mega
              EMPTY_ARRAY = []

              attr_accessor :raw

              def initialize(raw)
                @raw = raw
              end

              def attributes
                raw.attributes
              end

              private

              def at(locator)
                return nil if raw.nil?

                element = raw.locate(locator.to_s).first

                if element
                  StringWithAttributes.new(element.text, element.attributes)
                end
              end

              def has?(locator)
                raw.locate(locator).any?
              end

              def submodel_at(klass, locator)
                element_xml = raw.locate(locator).first

                klass.new(element_xml) if element_xml
              end

              def array_of_at(klass, locator)
                return EMPTY_ARRAY if raw.nil?

                elements = raw.locate([*locator].join('/'))

                elements.map do |element|
                  klass.new(element)
                end
              end

              def to_h_with_attrs
                hash = HashWithAttributes.new({}, attributes)

                hash
              end
            end
          end
        TEMPLATE
      end

      def base_builder_template
        <<~TEMPLATE
          module Builders
            module BaseBuilder
              attr_accessor :name, :data, :options

              def initialize(name, data = {}, options = {})
                @name = name
                @data = data || {}
                @options = options || {}
              end

              def to_xml
                encoding = options[:encoding]

                doc_options = { version: '1.0' }
                doc_options[:encoding] = encoding if encoding
                doc = Ox::Document.new(doc_options)
                doc << builder

                dump_options = { with_xml: true }
                dump_options[:encoding] = encoding if encoding
                Ox.dump(doc, dump_options)
              end

              def build_element(name, content)
                element = Ox::Element.new(name)
                if content.respond_to? :attributes
                  content.attributes.each { |k, v| element[k] = v }
                end

                if content.respond_to? :value
                  element << content.value if content.value
                else
                  element << content if content
                end
                element
              end
            end
          end
        TEMPLATE
      end

      def hash_with_attrs_template
        <<~TEMPLATE
          class HashWithAttributes
            def initialize(hash, attributes = nil)
              @hash = hash
              @attributes = attributes if attributes
            end

            def value
              @hash
            end

            def attributes
              @attributes ||= {}
            end

            def attributes=(attributes)
              @attributes = attributes
            end

            def ==(other)
              if other.respond_to?(:value) && other.respond_to?(:attributes)
                value == other.value && other.attributes == attributes
              else
                value == other
              end
            end

            def merge(other)
              merged_hash = value.merge other.value
              merged_attrs = attributes.merge other.attributes

              self.class.new(merged_hash, merged_attrs)
            end

            def key?(key)
              value.key? key
            end

            def [](key)
              value[key]
            end

            def []=(key, key_value)
              value[key] = key_value
            end

            def dig(*attrs)
              value.dig(*attrs)
            end
          end
        TEMPLATE
      end

      def mega_template
        <<~TEMPLATE
          module Mega
            def mega
              called_from = caller_locations[0].label
              included_modules = (self.class.included_modules - Class.included_modules - [Mega])
              included_modules.map { |m| m.instance_method(called_from).bind(self).call }
            end
          end
        TEMPLATE
      end

      def create_requires_template(classes)
        modules = classes.select { |cl| cl.is_a? Parser::Handlers::Module }
        classes = classes.select { |cl| cl.is_a? Parser::Handlers::Klass }
        with_inheritance, others = classes.partition { |klass| klass.inherit_from }

        requires = ['parsers/base_parser', 'builders/base_builder']
        modules.each do |klass|
          requires << "parsers/#{klass.name.underscore}"
          requires << "builders/#{klass.name.underscore}"
        end
        others.each do |klass|
          requires << "parsers/#{klass.name.underscore}"
          requires << "builders/#{klass.name.underscore}"
        end
        with_inheritance.each do |klass|
          requires << "parsers/#{klass.name.underscore}"
          requires << "builders/#{klass.name.underscore}"
        end

        if @options[:namespace]
          requires = requires.map { |r| r.prepend("#{@options[:namespace].underscore}/") }
        end

        requires.map { |r| "require '#{r}'" }.join("\n")
      end
    end
  end
end
