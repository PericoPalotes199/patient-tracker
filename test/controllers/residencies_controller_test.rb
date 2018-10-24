require 'test_helper'

class ResidenciesControllerTest < ActionController::TestCase
  setup do
    @residency = residencies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:residencies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create residency" do
    assert_difference('Residency.count') do
      post :create, residency: { name: @residency.name }
    end

    assert_redirected_to residency_path(assigns(:residency))
  end

  test "should show residency" do
    get :show, id: @residency
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @residency
    assert_response :success
  end

  test "should update residency" do
    patch :update, id: @residency, residency: { name: @residency.name }
    assert_redirected_to residency_path(assigns(:residency))
  end

  test "should destroy residency" do
    assert_difference('Residency.count', -1) do
      delete :destroy, id: @residency
    end

    assert_redirected_to residencies_path
  end
end
