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

    def query values
        if values.keys != @dataset.attribute_names(@class_var)
            raise "Query does not fit all variables"
        end
        node = @root
        while node.variable != @class_var
            if node.next_attribute
                if node.children.count > 1
                    val = values[node.next_attribute]
                    node = node.children.select do |child|
                        child.value == val
                    end[0]
                else
                    node = node.children[0]
                end
            end
        end
        node.value
    end

end
