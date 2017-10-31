require 'test_helper'

class InvitePeopleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get invite_people_index_url
    assert_response :success
  end

end
