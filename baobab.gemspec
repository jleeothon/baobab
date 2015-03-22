description = File::read('./README.md')

Gem::Specification.new do |s|
  s.name        = 'baobab'
  s.version     = '0.1.0'
  s.date        = '2015-03-22'
  s.summary     = "ID3 decision trees for machine learning in Ruby"
  s.description = description
  s.authors     = ["Johnny E. Lee Othon"]
  s.email       = 'jleeothon@gmail.com'
  s.files       = [
                   'lib/baobab.rb',
                   'lib/baobab/dataset.rb',
                   'lib/baobab/node.rb',
                   'lib/baobab/shannon.rb',
                   'lib/baobab/tree.rb'
                  ]
  s.homepage    =
    'https://github.com/jleeothon/baobab'
  s.license     = 'MIT'
end
