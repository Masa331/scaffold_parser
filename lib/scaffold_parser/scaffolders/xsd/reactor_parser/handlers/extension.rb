module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class Extension
            include Handlers::BaseHandler

            def element(child)
              Element.new(self, child)
            end

            def complete
              products.each { |product| parent_handler.push product }
              unless source.extending_basic_xsd_type?
                parent_handler.inherit_from = source.base
              end
              parent_handler
            end
          end
        end
      end
    end
  end
end
