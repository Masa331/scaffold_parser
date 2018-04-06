module ScaffoldParser
  module Scaffolders
    class XSD
      class Parser
        module Handlers
          module Base
            attr_accessor :wip

            def initialize(wip = nil)
              @wip = wip
            end

            def method_missing(sym, *args)
              name = sym.to_s.camelize.to_sym

              if Handlers.constants.include? name
                Handlers.const_get(name).new(wip)
              else
                super
                # path = "#{Dir.pwd}/lib/scaffold_parser/scaffolders/xsd/parser/handlers/#{name.underscore}.rb"
                #
                # template =
                #   <<~TEMPLATE
                #     module ScaffoldParser
                #       module Scaffolders
                #         class XSD
                #           class Parser
                #             module Handlers
                #               class Element
                #                 include Base
                #               end
                #             end
                #           end
                #         end
                #       end
                #     end
                #   TEMPLATE
                # template.gsub!('Element', name)
                # File.open(path, 'wb') { |f| f.write template }
                # require path
                # Handlers.const_get(name).new(wip)
              end
            end

            # def subclasses
            #   Handlers.constants
            # end

            # def respond_to?(sym, *args)
            #   name = sym.to_s.classify
            #
            #   if Handlers.const_defined? name
            #     true
            #   else
            #     super
            #   end
            # end
          end
        end
      end
    end
  end
end
