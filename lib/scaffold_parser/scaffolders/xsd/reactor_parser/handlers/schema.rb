module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class Schema
            include Handlers::BaseHandler

            def complex_type(child)
              ComplexType.new(self, child)
            end

            def push(product)
              @products.push product
              self
            end

            def complete
              parent_handler.push products
            end
          end
        end
      end
    end
  end
end
