require 'test_helper'

class VariantsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get variants_index_url
    assert_response :success
  end

  test "should get create" do
    get variants_create_url
    assert_response :success
  end

  test "should get update" do
    get variants_update_url
    assert_response :success
  end

  test "should get destroy" do
    get variants_destroy_url
    assert_response :success
  end

end
