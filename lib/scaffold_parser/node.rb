module ScaffoldParser
  class Node
    attr_accessor :name, :type
    attr_reader :nodes

    def initialize
      @nodes = []
    end

    def to_s
      title = type ? "#{name} (#{type})" : name

      if nodes.any?
        "#{title} \n #{nodes}"
      else
        "#{title} \n"
      end
    end
    alias_method :inspect, :to_s
  end
end
