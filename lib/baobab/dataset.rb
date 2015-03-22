
# Represents a dataset or subset thereof.
# Is an array of hashes where all hashes contain the same keys.
class Dataset < Array

    # Receives an array of hashes. All hashes must contain the same keys.
    def initialize data
        data.each do |row|
            self << row
        end
    end

    def self.from_json filename
        text = File.read(filename)
        self.new JSON.parse(text)
    end

    def attribute_names class_var
        self.column_names.reject{|name| name == class_var}
    end

    # Returns an array of the attribute names in the dataset
    # Careful: it's empty on an empty set.
    def column_names
        self[0].keys
    end

    # Returns an array of the values of an attribute in the dataset.
    # Careful: it's empty on an empty set.
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
        unless self.count.zero?
            self.count{|r| r[var] == val}.fdiv(self.count)
        else
            0
        end
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
