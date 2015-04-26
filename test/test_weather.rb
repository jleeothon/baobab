require 'minitest/autorun'

load 'baobab.rb'

class TestWeather < MiniTest::Test
    def setup
        @dataset = Baobab::Dataset::from_json('test/weather.json')
        @tree = Baobab::DecisionTree.new @dataset, 'play'
    end

    # Compare to Weka's
    # outlook = sunny
    # |  humidity = high: no
    # |  humidity = normal: yes
    # outlook = overcast: yes
    # outlook = rainy
    # |  windy = TRUE: no
    # |  windy = FALSE: yes
    def test_tree_representation
        e =
'ROOT (0.94)
  outlook => rainy (0.694)
    windy => TRUE (0.0)
      play => no (0.0)
    windy => FALSE (0.0)
      play => yes (0.0)
  outlook => overcast (0.694)
    play => yes (0.0)
  outlook => sunny (0.694)
    humidity => normal (0.0)
      play => yes (0.0)
    humidity => high (0.0)
      play => no (0.0)
'
        assert_equal e, @tree.to_s
    end

    def test_from_json
        example = {"outlook"=>"overcast", "temperature"=>"mild", "humidity"=>"high", "windy"=>"TRUE", "play"=>"yes"}
        assert_includes @dataset, example
    end
end
