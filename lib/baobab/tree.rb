require 'json'
require 'set'

class DecisionTree

    #  The first decision tree node
    attr_reader :root

    def initialize dataset, class_var
        entropy = dataset.entropy(class_var)
        @root = DecisionTreeNode.new self, nil, nil, entropy
    end

    def build_tree subset, node
        
    end

end

class DecisionTreeNode

    # A list of nodes
    attr_accessor :children

    # The variable on which this operates, a string
    attr_reader :variable

    # The value for the variable, a string
    attr_reader :value

    # The decision tree
    attr_reader :decision_tree

    attr_reader :entropy_before

    attr_accessor :next_variable

    def initialize decision_tree, variable, value, entropy_before
        @variable = variable
        @value = value
        @decision_tree = decision_tree
        @entropy_before = entropy_before
    end

end

# Represents a dataset. Is an array of hashes where all hashes contain the same
# keys.
class Dataset < Array

    # Receives an array of hashes. All hashes must contain the same keys.
    def initialize data
        data.each do |row|
            self << row
        end
        self.validate
    end

    def self.from_json filename
        text = File.read(filename)
        self.new JSON.parse(text)
    end

    # Returns an array of the attribute names in the dataset
    def attribute_names dataset
        dataset[0].keys
    end

    # Returns an array of the values of an attribute in the dataset
    def attribute_values attribute
        Set.new(self.map{|row| row[attribute]}).to_a
    end

    def entropy class_var, **conditions
        subset = self.select do |row|
            conditions.reduce(true) do |memo, (cond_var, cond_val)|
                memo and row[cond_var] == cond_val
            end
        end
        class_vals = self.attribute_values(class_var)
        class_vals.reduce(0) do |memo, class_val|
            memo + partial_entropy(probability(subset, class_var, class_val))
        end
    end

    def probability subset, class_var, class_val
        subset.count{|r| r[class_var] == class_val}.fdiv(subset.count)
    end

    def partial_entropy probability
        probability * Math::log2(1 / probability)
    end

    def validate
        raise 'Dataset is empty' if self.empty?
        self.reduce(self[0].keys) do |memo, row|
            if memo == row.keys then
                memo
            else
                raise 'Dataset is inconsistent'
            end
        end
        return nil
    end
end

