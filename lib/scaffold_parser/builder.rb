module ScaffoldParser
  class Builder
    def self.call(models, params = {})
      self.new(models, params).call
    end

    def initialize(models, params)
      @models = models
      @params = params
    end

    def call
      @models.each do |model|
        file_name = model.name.underscore
        path = @params.delete(:path) || "./tmp/#{file_name}.rb"

        File.open(path, 'wb') do |f|
          element_methods(model).each do |n|
            f.puts "require '#{n.name.underscore}'"
          end

          f.puts
          f.puts "class #{model.name.classify}"

          methods = at_methods(model).map do |method|
            at_method_template(method)
          end
          methods.each_with_index do |m, i|
            f.puts m
            f.puts unless i == (methods.size - 1)
          end

          f.puts if element_methods(model).any?

          methods = element_methods(model).map do |method|
            element_method_template(method)
          end
          methods.each_with_index do |m, i|
            f.puts m
            f.puts unless i == (methods.size - 1)
          end

          f.puts "end"
        end
      end
    end

    private

    def at_methods(model)
      model.nodes.select do |m|
        m.nodes.empty?
      end
    end

    def element_methods(model)
      model.nodes.select do |m|
        m.nodes.any?
      end
    end

    def at_method_template(method)
      <<-DEF
  def #{method.name.underscore}
    at '#{method.name}'
  end
      DEF
    end

    def element_method_template(method)
      klass = method.type || method.name.classify

      <<-DEF
  def #{method.name.underscore}
    element_xml = at '#{method.name}'

    #{klass}.new(element_xml) if element_xml
  end
      DEF
    end
  end
end
