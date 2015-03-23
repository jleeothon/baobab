# baobab

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

```
require `baobab` # if installed as a gem
load `baobab.rb` # if using a copy of the repo
```

Create your dataset from a JSON file. Your dataset should be a list of objects variable names and values as key-value pairs. See examples in the sample [tests](https://github.com/jleeothon/baobab/tree/master/test).

```
dataset = Dataset::from_json('test/breast-cancer-adapted.json')
```

Create a tree based on the dataaset and provide the name of the class variable.

```
tree = DecisionTree.new dataset, 'Class'
```

Check your decision tree:

```
puts @tree.to_s
```

You can make queries to your tree:

```
tree.query({"age" => "50-59", "menopause" => "ge40", "tumor-size" => "15-19",
            "inv-nodes" => "0-2", "node-caps" => "no", "deg-malig" => "1",
            "breast" => "right", "breast-quad" => "central",
            "irradiat" => "no"})
# non-recurrence-events <-- expected class
```

Fun!

## Sources of the datasets

The weather dataset has been adapted from the `weather.nominal.arff` that comes shipped with [Weka](http://www.cs.waikato.ac.nz/ml/weka/).

The transportation dataset was taken from the example data in [https://www.youtube.com/watch?v=wL9aogTuZw8](https://www.youtube.com/watch?v=wL9aogTuZw8).

The breast cancer dataset is adapted from the `breast-cancer.arff` file that comes shipped with Weka. It should be attributed to:

Matjaz Zwitter & Milan Soklic (physicians)
Institute of Oncology 
University Medical Center
Ljubljana, Yugoslavia
Donors: Ming Tan and Jeff Schlimmer (Jeffrey.Schlimmer@a.gp.cs.cmu.edu)
Date: 11 July 1988
