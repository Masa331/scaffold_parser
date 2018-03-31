module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class ComplexType
            include Handlers::BaseHandler

            def element(child)
              Element.new(self, child)
            end

            def complete
              template = ClassTemplate.new(@source.name.classify) do |template|
                template.methods = products
              end

              parent_handler.push template
            end

            def push(product)
              if product.is_a?(AtMethodTemplate) || product.is_a?(SubmodelMethodTemplate) || product.is_a?(ListMethodTemplate) || product.is_a?(StringListMethodTemplate)
                @products.push product
                self
              else
                parent_handler.push product
                self
              end
            end
          end
        end
      end
    end
  end
end
