require 'minitest/autorun'

load 'baobab.rb'

class TestTransportation < MiniTest::Test
    def setup
        @dataset = Dataset::from_json("test/transportation.json")
        @tree = DecisionTree.new @dataset, 'transportation'
    end

    def test_tree_representation
        e =
"ROOT (1.571)
  cost => expensive (0.361)
    transportation => car (0.0)
  cost => standard (0.361)
    transportation => train (0.0)
  cost => cheap (0.361)
    gender => female (0.4)
      transportation => train (0.0)
    gender => male (0.4)
      transportation => bus (0.0)
"
        assert_equal e, @tree.to_s
    end

    def test_from_json
        example = {"gender"=>"male", "owns car"=>"0", "cost"=>"cheap", "income"=>"low", "transportation"=>"bus"}
        assert_includes @dataset, example
    end

    def test_tree_entropy
        assert_in_delta @tree.root.entropy, 1.5709
    end

    def test_query_1
        r = @tree.query({"gender"=>"male", "owns car"=>1, "cost"=>"standard", "income"=>"high"})
        assert_equal 'train', r
    end

    def test_query_2
        r = @tree.query({"gender"=>"female", "owns car"=>1, "cost"=>"cheap", "income"=>"high"})
        assert_equal 'train', r
    end
end
