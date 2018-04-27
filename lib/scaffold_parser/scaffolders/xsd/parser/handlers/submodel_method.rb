module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class SubmodelMethod
            include BaseMethod
            include Utils

            attr_accessor :submodel_class

            def initialize(source, submodel_class = nil)
              @source = source
              @submodel_class = submodel_class || source.type.camelize
            end

            def method_body
              "submodel_at(#{submodel_class}, '#{source.name}')"
            end

            def to_h_with_attrs_method
              "hash[:#{method_name}] = #{method_name}.to_h_with_attrs if has? '#{source.name}'"
            end

            def to_builder
              f = StringIO.new

              f.puts "if data.key? :#{method_name}"
              f.puts "  root << #{submodel_class}.new('#{source.name}', data[:#{source.name.underscore}]).builder"
              f.puts 'end'

              f.string.strip
            end

            def sequence(_)
              Sequence.new self
            end

            def choice(_)
              Choice.new self
            end

            def all(_)
              All.new self
            end

            def schema(_)
              STACK
            end

            def to_at_method
              AtMethod.new(source)
            end
          end
        end
      end
    end
  end
end
