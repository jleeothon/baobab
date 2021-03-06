require 'json'
require 'set'

module Baobab

  class DecisionTree

    #  The first decision tree node
    attr_reader :root

    # The class variable of interest in this decision tree.
    attr_reader :class_var

    # The underlying dataset
    attr_reader :dataset

    # Receives
    # - dataset, a list of hashes
    # - the name of the class variable
    def initialize dataset, class_var
      @dataset = dataset
      if class_var.nil?
        raise "class_var cannot be nil"
      end
      @class_var = class_var
      entropy = dataset.entropy class_var
      @root = DecisionTreeNode.new(
        self, parent=nil,
        attribute=nil, value=nil,
        entropy
        )
      @root.build_subtree
    end

    # Prints the decision depth-first with the respective entropy values.
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
      s
    end

    # Receives attributes and their values (they must be all defined).
    # Returns the value of the predicted class value.
    def query values
      if values.keys.sort != @dataset.attribute_names(@class_var).sort
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

end
