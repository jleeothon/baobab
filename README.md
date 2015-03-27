# baobab [![Build Status](https://travis-ci.org/jleeothon/baobab.svg?branch=master)](https://travis-ci.org/jleeothon/baobab)

An implementation of the ID3 (Iterative Dichotomiser 3) in Ruby

## Installation

Use RubyGems:

```
gem install baobab
```

## How to run the tests

```
rake tests
```

## Usage

Load `baobab`:

```Ruby
require `baobab` # if installed as a gem
load `baobab.rb` # if using a copy of the repo
```

Create your dataset from a JSON file. Your dataset should be a list of objects variable names and values as key-value pairs. See examples in the sample [tests](https://github.com/jleeothon/baobab/tree/master/test).

```Ruby
# A dataset on whether or not we go out to play depending on the outlook,
# humidity, and if it's windy
dataset = Dataset::from_json('test/weather.json')
```

Create a tree based on the dataaset and provide the name of the class variable.

```Ruby
tree = DecisionTree.new dataset, 'play'
```

Check your decision tree:

```Ruby
puts tree.to_s
# ROOT (0.94) # the number parenthesized is Shannon's entropy
#   outlook => rainy (0.694)
#     windy => TRUE (0.0)
#       play => no (0.0)
#     windy => FALSE (0.0)
#       play => yes (0.0)
#   outlook => overcast (0.694)
#     play => yes (0.0)
#   outlook => sunny (0.694)
#     humidity => normal (0.0)
#       play => yes (0.0)
#     humidity => high (0.0)
#       play => no (0.0)
```

You can make queries to your tree:

```Ruby
tree.query({"windy" => "yes", "outlook" => "rainy", "humidity" => "high"})
# no <-- we won't go out to play :(
```

Fun!

## Sources of the datasets

The weather dataset has been adapted from the `weather.nominal.arff` that comes shipped with [Weka](http://www.cs.waikato.ac.nz/ml/weka/).

The transportation dataset was taken from the example data in [https://www.youtube.com/watch?v=wL9aogTuZw8](https://www.youtube.com/watch?v=wL9aogTuZw8).

The breast cancer dataset is adapted from the `breast-cancer.arff` file that comes shipped with Weka (adapted so it doesn't have unknown values). It should be attributed to:

Matjaz Zwitter & Milan Soklic (physicians), Institute of Oncology, University Medical Center, Ljubljana, Yugoslavia. Donors: Ming Tan and Jeff Schlimmer (Jeffrey.Schlimmer@a.gp.cs.cmu.edu). Date: 11 July 1988.
