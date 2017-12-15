require 'test_helper'

class LogReadingControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get log_reading_show_url
    assert_response :success
  end

end
