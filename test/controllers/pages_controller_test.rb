require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  # was the web request successful?
  # was the user redirected to the right page?
  # was the user successfully authenticated?
  # was the correct object stored in the response template?
  # was the appropriate message displayed to the user in the view?

  setup do
    @residency_admin = users(:residency_admin)
    @resident = users(:resident)
  end

  test "As a visitor, I can visit the home page" do
    get :index
    assert_response :success
  end

  test "As a signed in resident, when I visit the home page, I am redirected" do
    sign_in @resident
    get :index
    assert_response :redirect
    assert_redirected_to new_encounter_path
  end

  test "As a signed in admin, when I visit the home page, I am redirected" do
    sign_in @residency_admin
    get :index
    assert_response :redirect
    assert_redirected_to users_path
  end

end
