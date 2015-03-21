require 'baobab'

dataset = Dataset::from_json("test/dataset.json")
puts(dataset)
t = DecisionTree.new dataset, 'transportation'
puts t.root.entropy_before
