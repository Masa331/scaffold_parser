module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          module BaseHandler
            attr_reader :parent_handler, :products

            def initialize(parent_handler)
              @parent_handler = parent_handler
              @products = []
            end

            def push(product)
              @products.push product
              self
            end

            def complete
              @parent_handler.push product
            end
          end
        end
      end
    end
  end
end
