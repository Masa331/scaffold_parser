module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class XSD
            include BaseHandler

            def document(_)
              Document.new(self)
            end

            def complete
              products.map &:to_s
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
