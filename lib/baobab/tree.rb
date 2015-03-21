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
        @root = DecisionTreeNode.new self, nil, nil, entropy
        @root.build_subtree
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
    attr_reader :tree

    attr_reader :entropy_before

    attr_accessor :next_variable

    # Accumulates the conditions down the tree
    attr_reader :conditions

    # The conditional probability that variable=value
    attr_reader :probability

    def initialize tree, variable, value, entropy_before, conditions=nil
        @variable = variable
        @value = value
        @tree = tree
        @entropy_before = entropy_before
        @conditions = if conditions then conditions else {} end
    end

    def subset
        Dataset.new(self.tree.dataset.subset(self.conditions))
    end

    def pending_attrs
        self.tree.dataset.column_names.reject do |name|
            self.tree.class_var == name or @conditions.include? name
        end
    end

    def build_subtree
        subset = self.subset
        subset_count = self.subset.count
        entropies = self.entropies
        inf_gain = entropies.each.with_object({}) do |(a, e), o|
            o[a] = @entropy_before - e
        end
        puts entropies
        puts inf_gain
    end

    # Returns a hash of {attribute, entropy} given that we divide the dataset
    # on attribute.
    def entropies
        self.pending_attrs.each.with_object({}) do |a, o|
            values = self.tree.dataset.column_values(a)
            val_probabilities = values.each.with_object({}) do |v, o|
                o[v] = subset.probability a, v
            end
            val_entropies = values.each.with_object({}) do |v, o|
                o[v] = subset.subset({a => v}).entropy(self.tree.class_var)
            end
            o[a] = values.reduce(0) do |memo, v|
                memo += val_entropies[v] * val_probabilities[v]
            end
        end
    end
end

# Represents a dataset or subset thereof.
# Is an array of hashes where all hashes contain the same keys.
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

    def attribute_names class_var
        self.column_names.reject{|name| name == class_var}
    end

    # Returns an array of the attribute names in the dataset
    def column_names
        self[0].keys
    end

    # Returns an array of the values of an attribute in the dataset
    def column_values attribute
        Set.new(self.map{|row| row[attribute]}).to_a
    end

    # Gets a subset with given conditions. Keys must be of the same type as
    # in the dataset (be careful with symbols).
    def subset conditions
        rows = self.select do |row|
            conditions.reduce(true) do |memo, (var, val)|
                memo and row[var] == val
            end
        end
        Dataset.new rows
    end

    def entropy class_var
        class_vals = self.column_values(class_var)
        probabilities = class_vals.map do |class_val|
            self.probability(class_var, class_val)
        end
        Shannon::entropy *probabilities
    end

    # Evaluates the probability that var be val in this dataset.
    # Can also be used for subsets.
    def probability var, val
        self.count{|r| r[var] == val}.fdiv(self.count)
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

module Shannon

    def self.entropy *probabilities
        probabilities.reduce(0) do |memo, p|
            memo + self.entropy_term(p)
        end
    end

    def self.entropy_term probability
        probability * Math::log2(1 / probability)
    end
end
