module ScaffoldParser
  class Builder
    def self.call(model, params = {})
      path = params.delete(:path) || "./tmp/#{model.file_name}"

      File.open(path, 'wb') do |f|
        f.puts "class #{model.name}"

        methods = model.methods.map do |method|
          method_template(method)
        end
        methods.each_with_index do |m, i|
          f.puts m
          f.puts unless i == (methods.size - 1)
        end

        f.puts "end"
      end
    end

    private

    def self.method_template(method)
      <<-DEF
  def #{method[:name]}
    at '#{method[:at]}'
  end
      DEF
    end
  end
end
