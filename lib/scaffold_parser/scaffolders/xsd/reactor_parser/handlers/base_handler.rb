module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          module BaseHandler
            attr_accessor :parent_handler, :products, :source

            def initialize(parent_handler, source = nil)
              @parent_handler = parent_handler
              @source = source
              @products = []
            end

            def handle(child)
              send child.element_name, child
            end

            def push(product)
              @products.push product
              self
            end
          end
        end
      end
    end
  end
end
