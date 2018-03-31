module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class Document
            include Handlers::BaseHandler

            def schema
              Schema.new(self)
            end

            def product
              products
            end

            def push(product)
              @products = product
              self
            end
          end
        end
      end
    end
  end
end
