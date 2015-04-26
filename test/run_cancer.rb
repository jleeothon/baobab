load 'baobab.rb'

dataset = Baobab::Dataset::from_json('test/breast-cancer-adapted.json')
tree = Baobab::DecisionTree.new dataset, 'Class'
puts tree.to_s
