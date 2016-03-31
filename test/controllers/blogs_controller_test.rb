require 'test_helper'

class BlogsControllerTest < ActionController::TestCase
  test "should get about" do
    get :about
    assert_response :success
    assert_template layout: 'layouts/application'
    assert_template :about
  end
end
