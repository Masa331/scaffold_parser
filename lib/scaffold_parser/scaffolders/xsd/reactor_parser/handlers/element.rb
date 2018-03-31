module ScaffoldParser
  module Scaffolders
    class XSD
      class ReactorParser
        module Handlers
          class Element
            include Handlers::BaseHandler

            attr_accessor :inherit_from

            def element(child)
              Element.new(self, child)
            end

            def extension(child)
              Extension.new(self, child)
            end

            def complete
              if inherit_from
                template = SubmodelMethodTemplate.new(source, source.name.camelize)
                parent_handler.push template

                template = ClassTemplate.new(source.name.classify) do |template|
                  template.methods = products
                  template.inherit_from = inherit_from.classify
                end
                parent_handler.push template
              elsif source.multiple?
                template =
                  if source.type.nil? || source.basic_xsd_type?
                    StringListMethodTemplate.new(source)
                  else
                    ListMethodTemplate.new(source)
                  end
                parent_handler.push template
              elsif source.custom_type?
                template = SubmodelMethodTemplate.new(source, source.type.classify)
                parent_handler.push template
              elsif products.empty?
                template = AtMethodTemplate.new(source)
                parent_handler.push template
              elsif products.size == 1 && (products.first.is_a?(ListMethodTemplate) || products.first.is_a?(StringListMethodTemplate))
                template =
                  if products.first.is_a?(ListMethodTemplate)
                    ListMethodTemplate.new(source)
                  else
                    StringListMethodTemplate.new(source)
                  end

                template.at = products.first.at.unshift source.name
                template.item_class = products.first.item_class

                parent_handler.push template
              else # this is actually a anonymous type
                template = SubmodelMethodTemplate.new(source, source.name.classify)
                parent_handler.push template

                template = ClassTemplate.new(source.name.classify) do |template|
                  template.methods = products
                end
                parent_handler.push template
              end
            end
          end
        end
      end
    end
  end
end
