require 'json'
require 'set'

class DecisionTree

    #  The first decision tree node
    attr_reader :root

    # The class variable of interest in this decision tree.
    attr_reader :class_var

    # The underlying dataset
    attr_reader :dataset

    def initialize dataset, class_var
        @dataset = dataset
        @class_var = class_var
        entropy = dataset.entropy class_var
        @root = DecisionTreeNode.new(
            self, parent=nil,
            attribute=nil, value=nil,
            entropy
            )
        @root.build_subtree
    end

    def to_s
        s = ""
        nodes = [[0, @root]]
        while nodes.any?
            l, n = nodes.last
            nodes = nodes.slice(0...-1)
            n.children.each do |c|
                nodes << [l + 1, c]
            end
            s = s + "#{' ' * (l * 2)}#{n.to_s}\n"
        end
        return s
    end

end
