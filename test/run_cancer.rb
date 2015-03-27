load 'baobab.rb'

dataset = Dataset::from_json('test/breast-cancer-adapted.json')
tree = DecisionTree.new dataset, 'Class'
puts tree.to_s
