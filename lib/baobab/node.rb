module Baobab

  class DecisionTreeNode

      # A list of nodes
      attr_accessor :children

      # The variable on which this operates, a string
      attr_reader :variable

      # The value for the variable, a string
      attr_reader :value

      # The decision tree
      attr_reader :tree

      attr_reader :entropy

      attr_accessor :next_attribute

      # Accumulates the conditions down the tree
      attr_reader :conditions

      # The conditional probability that variable=value
      attr_reader :probability

      def initialize tree, parent, variable, value, entropy, conditions=nil
          @tree = tree
          @parent = parent
          @variable = variable
          @value = value
          @entropy = entropy
          @conditions = conditions ? conditions : {}
          @children = Array.new
          @subset = nil
      end

      def to_s
          s = @variable ? "#{@variable} => #{@value}" : "ROOT"
          s += " (#{@entropy.round(3)})"
      end

      def subset
          unless @subset.nil?
             @subset
          else
              @subset = @tree.dataset.subset(self.full_conditions)
          end
      end

      def clear
          @subset = nil
      end

      def pending_attrs
          @tree.dataset.column_names.reject do |name|
              @tree.class_var == name or @conditions.include? name
          end
      end

      # Returns a subset selected on all the parent node's conditions plus this
      # node's attribute and its value.
      def full_conditions
          if @variable
              conditions.merge({@variable => @value})
          else
              conditions
          end
      end

      def build_subtree recursive=true
          if self.try_finish
              return
          end
          subset = self.subset
          subset_count = self.subset.count
          entropies = self.entropies
          inf_gain = entropies.each.with_object({}) do |(a, e), o|
              o[a] = @entropy - e
          end
          max_attr, max_gain = inf_gain.max_by{|v, g| g}
          self.next_attribute = max_attr
          @children += self.tree.dataset.column_values(max_attr).map do |value|
              conditions = self.full_conditions
              DecisionTreeNode.new(
                  tree=@tree, parent=self,
                  attribute=max_attr, value=value,
                  entropy=entropies[max_attr], conditions=conditions
              )
          end
          if recursive
              @children.each do |c|
                  c.build_subtree
              end
          end
      end

      # Checks whether any of three is true:
      # - All elements in the subset belong to the same class value: a leaf with
      # this value is created.
      # - There are no more attributes to be selected: a leaf with the most common
      # class value is selected
      # - There are no more rows in the dataset: a leaf with the most common class
      # value in the parent node is created.
      def try_finish
          var = self.tree.class_var
          val = (
              self.try_finish_single_value_class or
              self.try_finish_empty_subset or
              self.try_finish_no_more_attributes
              )
          if val
              @next_attribute = @tree.class_var
              self.children << DecisionTreeNode.new(
                  tree=@tree, parent=self,
                  variable=@tree.class_var, value=val,
                  entropy=0, conditions=self.full_conditions
                  )
          else
              false
          end
      end

      # If all class values are the same, returns that value; else, nil.
      def try_finish_single_value_class
          if self.subset.any?
              v0 = self.subset[0][@tree.class_var]
              self.subset.slice(1...-1).reduce(v0) do |memo, row|
                  if memo != row[@tree.class_var]
                      return nil
                  else
                      memo
                  end
              end
          else
              nil
          end

      end

      # If there are not more attributes, returns the most common class value;
      # else, nil.
      def try_finish_no_more_attributes
          if self.pending_attrs.empty? then
              self.most_common_value
          else
              nil
          end
      end

      # If the subset is empty, returns the most common value in the parent
      # node's subset.
      def try_finish_empty_subset
          if self.subset.empty?
              @parent.most_common_value
          else
              nil
          end
      end

      # Returns the most common class value in the dataset.
      def most_common_value
          class_var = @tree.class_var
          class_values = @tree.dataset.column_values(class_var)
          count = class_values.each.with_object({}) do |val, o|
              o[val] = 0
          end
          self.subset.each.with_object(count) do |row, o|
              count[row[class_var]] += 1
          end
          count.max_by{|v, c| c}[0]
      end

      # Returns a hash of {attribute, entropy} given that we divide the dataset
      # on attribute.
      def entropies
          self.pending_attrs.each.with_object({}) do |a, o|
              values = @tree.dataset.column_values(a)
              val_probabilities = values.each.with_object({}) do |v, o|
                  o[v] = subset.probability a, v
              end
              val_entropies = values.each.with_object({}) do |v, o|
                  o[v] = subset.subset({a => v}).entropy(self.tree.class_var)
              end
              o[a] = values.reduce(0) do |memo, v|
                  memo + val_entropies[v] * val_probabilities[v]
              end
          end
      end
  end

end
