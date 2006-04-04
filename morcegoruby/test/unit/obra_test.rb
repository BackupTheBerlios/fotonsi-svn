require File.dirname(__FILE__) + '/../test_helper'

class ObraTest < Test::Unit::TestCase
  fixtures :obras

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Obra, obras(:first)
  end
end
