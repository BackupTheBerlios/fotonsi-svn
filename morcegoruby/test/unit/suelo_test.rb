require File.dirname(__FILE__) + '/../test_helper'

class SueloTest < Test::Unit::TestCase
  fixtures :suelos

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Suelo, suelos(:first)
  end
end
