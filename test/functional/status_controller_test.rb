require 'test_helper'

class StatusControllerTest < ActionController::TestCase
  test "should get clone" do
    get :clone
    assert_response :success
  end

  test "should get build" do
    get :build
    assert_response :success
  end

end
