require File.dirname(__FILE__) + '/../test_helper'

class PromotorTest < Test::Unit::TestCase
  fixtures :promotors

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Promotor, promotors(:first)
  end
end
