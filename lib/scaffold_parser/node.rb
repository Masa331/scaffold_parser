module ScaffoldParser
  class Node
    attr_accessor :name, :type, :element_type
    attr_reader :nodes

    def initialize
      @nodes = []
    end

    def to_class_name
      if type
        type.classify
      else
        name.classify
      end
    end

    def to_file_name
      to_class_name.underscore
    end

    def to_require
      to_class_name.underscore
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
