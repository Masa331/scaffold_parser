module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class Schema
            include Handlers::BaseHandler

            def complex_type
              ComplexType.new(self)
            end

            def product
              products
            end
          end
        end
      end
    end
  end
end
