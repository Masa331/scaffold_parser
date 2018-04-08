module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Templates
          class SimpleTypeKlass
            include Utils

            attr_accessor :name, :namespace, :methods, :inherit_from

            def initialize(name = nil)
              @name = name
              @methods = []

              yield self if block_given?
            end

            def ==(other)
              name == other.name &&
                namespace == other.namespace &&
                methods == other.methods &&
                inherit_from == other.inherit_from
            end
          end
        end
      end
    end
  end
end
