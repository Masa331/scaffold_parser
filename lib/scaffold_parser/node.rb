module ScaffoldParser
  class Node
    attr_accessor :name, :nodes

    def initialize
      @nodes = []
    end
  end
end
