require 'test_helper'

class EncountersControllerTest < ActionController::TestCase

  # was the web request successful?
  # was the user redirected to the right page?
  # was the user successfully authenticated?
  # was the correct object stored in the response template?
  # was the appropriate message displayed to the user in the view?

  setup do
    @resident = users(:resident)
    @residency_admin = users(:residency_admin)
    @encounter = @resident.encounters.first
  end

  test "As a visitor, I cannot visit the encounters index" do
    get :index
    assert_nil assigns(:encounters)
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can view only my encounters at the encounters index" do
    sign_in @resident
    get :index
    assert_response :success
    assert_equal assigns(:encounters).count, @resident.encounters.count
    assert_equal assigns(:encounters), @resident.encounters.order(encountered_on: :desc)
    assert_template :index
  end

  test "As a resident, when I visit the encounters index, encounters are reverse sorted by encountered_on" do
    sign_in @resident
    get :index
    assert_equal assigns(:encounters).pluck(:encountered_on), @resident.encounters.pluck(:encountered_on).sort.reverse
  end

  test "As an admin, I can view all of my invited residents' encounters at the encounters index" do
    sign_in @residency_admin
    get :index
    assert_response :success
    expected_encounters = []
    @residency_admin.invitations.each do |invitation|
      expected_encounters += invitation.encounters
    end
    assert_equal assigns(:encounters).pluck(:id).sort, expected_encounters.map{ |encounter| encounter.id }.sort
    assert_template :index
  end

  test "As an admin, when I visit the encounters index, encounters are sorted by [TBD]" do
    skip
    sign_in @residency_admin
    get :index
  end

  test "As a visitor, I cannot visit the new encounter form" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As I resident, I can visit the new encounter page" do
    sign_in @resident
    get :new
    assert_response :success
    assert_template :new
  end

  test "As an admin, I can visit the new encounter page" do
    sign_in @residency_admin
    get :new
    assert_response :success
    assert_template :new
  end

  test "As a visitor, I cannot create an encounter" do
    assert_no_difference('Encounter.count') do
      post :create, encounter: { encounter_types: {adult_inpatient: 1, adult_ed: 2} }
    end
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can create an encounter" do
    sign_in @resident
    assert_difference('Encounter.count', 3) do
      post :create, encounter_types: {adult_inpatient: 1, adult_ed: 2}, encountered_on: Time.now.to_date
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As an admin, I cannot create an encounter" do
    sign_in @residency_admin
    assert_no_difference('Encounter.count') do
      post :create, encounter_types: {adult_inpatient: 1, adult_ed: 2}, encountered_on: Time.now.to_date
    end
    assert_response :redirect

    assert_redirected_to encounters_path
  end

  test "As a visitor, I cannot view an encounter" do
    get :show, id: @encounter
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can view one of my encounters" do
    sign_in @resident
    get :show, id: @encounter
    assert_response :success
    assert_template :show
  end

  test "As a resident, I cannot view an encounter that is not mine" do
    sign_in @resident
    get :show, id: users(:resident_1).encounters.first
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As an admin, I cannot view single encounters" do
    sign_in @residency_admin
    get :show, id: @encounter
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As a visitor, I cannot edit encounters" do
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @encounter
    end
  end

  test "As a resident, I cannot edit encounters" do
    sign_in @resident
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @encounter
    end
  end

  test "As an admin, I cannot edit encounters" do
    sign_in @residency_admin
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @encounter
    end
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @residency_admin.invitations.first.encounters.first
    end
  end

  test "As a visitor, I cannot update encounters" do
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @encounter
    end
  end

  test "As a resident, I cannot update encounters" do
    sign_in @resident
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @encounter
    end
  end

  test "As an admin, I cannot update encounters" do
    sign_in @residency_admin
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @encounter
    end
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @residency_admin.invitations.first.encounters.first
    end
  end

  test "As a visitor, I cannot destroy encounters" do
    assert_no_difference('Encounter.count') do
      delete :destroy, id: @encounter
    end

    assert_redirected_to new_user_session_path
  end

  test "As a resident, I cannot destroy encounters that are not mine" do
    sign_in @resident
    assert_no_difference('Encounter.count') do
      delete :destroy, id: users(:resident_1).encounters.first
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As a resident, I can destroy my own encounters" do
    sign_in @resident
    assert_difference('Encounter.count', -1) do
      delete :destroy, id: @encounter
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As an admin, I cannot destroy encounters" do
    sign_in @residency_admin
    assert_no_difference('Encounter.count') do
      delete :destroy, id: users(:resident_1).encounters.first
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end
end
