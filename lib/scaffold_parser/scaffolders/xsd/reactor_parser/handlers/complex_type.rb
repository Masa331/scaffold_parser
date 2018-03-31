module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class ComplexType
            include Handlers::BaseHandler

            def complex_type
              ComplexType.new(self)
            end

            def product
              ClassTemplate.new('lol')
            end
          end
        end
      end
    end
  end
end
