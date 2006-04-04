require File.dirname(__FILE__) + '/../test_helper'
require 'morcego_controller'

class MorcegoController; def rescue_action(e) raise e end; end

class MorcegoControllerApiTest < Test::Unit::TestCase
  def setup
    @controller = MorcegoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_getSubGraph
    result = invoke :getSubGraph
    assert_equal nil, result
  end

  def test_isNodePresent
    result = invoke :isNodePresent
    assert_equal nil, result
  end
end
