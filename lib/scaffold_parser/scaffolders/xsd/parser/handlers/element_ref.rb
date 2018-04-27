module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          class ElementRef
            def initialize(source)
              @source = source
            end

            def to_submodel_method(ref_map)
              name = ref_map[@source.ref].split(':').map(&:classify).join('::')

              SubmodelMethod.new(@source, name)
            end
          end
        end
      end
    end
  end
end
