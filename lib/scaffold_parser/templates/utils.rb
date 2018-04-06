module ScaffoldParser
  module Templates
    module Utils
      def indent(lines_or_string)
        if lines_or_string.is_a? Array
          lines_or_string.map { |line| indent_string(line) }
        else
          indent_string(lines_or_string)
        end
      end

      def indent_string(string)
        string == "\n" ? string : string.prepend('  ')
      end

      def single_quote(string)
        string.to_s.gsub('"', '\'')
      end
    end
  end
end
