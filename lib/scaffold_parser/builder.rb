module ScaffoldParser
  class Builder
    def self.call(model, params = {})
      self.new(model, params).call
    end

    def initialize(model, params)
      @model = model
      @params = params
    end

    def call
      require 'pry'; binding.pry
      path = @params.delete(:path) || "./tmp/#{@model.file_name}"

      File.open(path, 'wb') do |f|
        f.puts "class #{@model.name}"

        methods = at_methods.map do |method|
          at_method_template(method)
        end
        methods.each_with_index do |m, i|
          f.puts m
          f.puts unless i == (methods.size - 1)
        end

        f.puts "end"
      end
    end

    private

    def at_methods
      @model.methods.select { |m| m[:class].blank? }
    end

    def element_methods
      @model.methods.select { |m| m[:class].present? }
    end

    def at_method_template(method)
      <<-DEF
  def #{method[:name]}
    at '#{method[:at]}'
  end
      DEF
    end

    def element_method_template(method)
      <<-DEF
  def #{method[:name]}
    at '#{method[:at]}'
  end
      DEF
    end
  end
end
