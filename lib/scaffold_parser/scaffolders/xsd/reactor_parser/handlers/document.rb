module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class Document
            include Handlers::BaseHandler

            def schema(_)
              Schema.new(self)
            end

            def push(product)
              @products = product
              self
            end

            def complete
              self
            end
          end
        end
      end
    end
  end
end
