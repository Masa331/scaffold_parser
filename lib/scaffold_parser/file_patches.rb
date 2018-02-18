module ScaffoldParser
  module FilePatches
    attr_accessor :indent

    def putsi(str)
      if indent
        puts str.prepend('  ')
      else
        puts str
      end
    end
  end
end
