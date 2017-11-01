require 'test_helper'

class RequestProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @request_product = request_products(:one)
  end

  test "should get index" do
    get request_products_url
    assert_response :success
  end

  test "should get new" do
    get new_request_product_url
    assert_response :success
  end

  test "should create request_product" do
    assert_difference('RequestProduct.count') do
      post request_products_url, params: { request_product: { link: @request_product.link, product_name: @request_product.product_name, status: @request_product.status } }
    end

    assert_redirected_to request_product_url(RequestProduct.last)
  end

  test "should show request_product" do
    get request_product_url(@request_product)
    assert_response :success
  end

  test "should get edit" do
    get edit_request_product_url(@request_product)
    assert_response :success
  end

  test "should update request_product" do
    patch request_product_url(@request_product), params: { request_product: { link: @request_product.link, product_name: @request_product.product_name, status: @request_product.status } }
    assert_redirected_to request_product_url(@request_product)
  end

  test "should destroy request_product" do
    assert_difference('RequestProduct.count', -1) do
      delete request_product_url(@request_product)
    end

    assert_redirected_to request_products_url
  end
end
