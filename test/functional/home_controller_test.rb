require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get rankbygoogle" do
    get :rankbygoogle
    assert_response :success
  end

  test "should get rankbybaidu" do
    get :rankbybaidu
    assert_response :success
  end

end
