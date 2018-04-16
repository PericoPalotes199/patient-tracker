require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  # was the web request successful?
  # was the user redirected to the right page?
  # was the user successfully authenticated?
  # was the correct object stored in the response template?
  # was the appropriate message displayed to the user in the view?

  setup do
    @resident = users(:resident)
    @admin = users(:admin)
    @another_residency_admin = users(:another_residency_admin)
  end

  # UsersController#index

  test "As a visitor, I will see no users when I visit the users index" do
    get :index
    assert_response :redirect
    assert_nil assigns(:users)
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can visit the users index" do
    sign_in @resident
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:users).count > 0
    assert_template :index
  end

  test "As an admin, I can visit the users index" do
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil  assigns(:users).count > 0
    assert_template :index
  end

  # UsersController#show

  test "As a visitor, I cannot view a resident" do
    get :show, id: @resident
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a visitor, I cannot view an admin" do
    get :show, id: @admin
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can view my user record" do
    sign_in @resident
    get :show, id: @resident
    assert_response :success
    assert_template :show
  end

  test "As a resident, I cannot view another resident" do
    sign_in @resident
    get :show, id: users(:resident_1)
    assert_response :redirect
    assert_redirected_to @resident
  end

  test "As a resident, I cannot view an admin" do
    sign_in @resident
    get :show, id: @admin
    assert_response :redirect
    assert_redirected_to @resident
  end

  test "As an admin, I can view my user record" do
    sign_in @admin
    get :show, id: @admin
    assert_response :success
    assert_template :show
  end

  test "As an admin, I can view residents that were invited by me" do
    sign_in @admin
    get :show, id: users(:resident_1)
    assert_response :success
    assert_template :show
  end

  test "As an admin, I cannot view residents that were not invited by me" do
    sign_in @another_residency_admin
    get :show, id: @resident
    assert_response :redirect
    assert_redirected_to @another_residency_admin
  end

  # UsersController#edit

  test "As a visitor, I cannot edit a user" do
    get :edit, id: users(:resident).id
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can edit my user record " do
    sign_in @resident
    get :edit, id: users(:resident)
    assert_response :success
    assert_equal assigns(:user), @resident
    assert_template :edit
  end

  test "As a resident, I cannot edit other user records" do
    sign_in @resident
    get :edit, id: users(:resident_1)
    assert_equal assigns(:user), users(:resident_1)
    assert_response :redirect
    assert_redirected_to @resident
  end

  test "As an admin, I cannot edit user records not invited by me" do
    sign_in @another_residency_admin
    get :edit, id: @resident
    assert_equal assigns(:user), @resident
    assert_response :redirect
    assert_redirected_to users_path
  end

  test "As an admin, I can edit user records invited by me" do
    sign_in @admin
    get :edit, id: users(:resident_1)
    assert_equal assigns(:user), users(:resident_1)
    assert_response :success
    assert_template :edit
  end

  test "As a visitor, I cannot update other user records" do
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I cannot update my own user record, if I have not accepted the tos" do
    sign_in @resident
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :success
    assert_template :edit
  end

  test "As a resident, I can update my own user record, if I accept the tos" do
    sign_in @resident
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated', tos_accepted: true }
    assert_response :redirect
    assert_redirected_to @resident
  end

  test "As a resident, I cannot update another resident" do
    sign_in @resident
    patch :update, id: users(:resident_1), user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to @resident
  end

  test "As a resident, I cannot update an admin" do
    sign_in @resident
    patch :update, id: @admin, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to @resident
  end

  test "As an admin, when I update one of my invited residents that has not accepted the tos, the edit form renders" do
    sign_in @admin
    patch :update, id: users(:resident_1), user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :success
    assert_template :edit
  end

  test "As an admin, when I update one of my invited residents that has accepted the tos, I am redirected" do
    sign_in @admin
    users(:resident_1).update!(tos_accepted: true)
    patch :update, id: users(:resident_1), user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to users(:resident_1)
  end

  test "As an admin, I cannot update user records not invited by me" do
    sign_in @another_residency_admin
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to users_path
  end

  test "As a visitor, I cannot destroy users" do
    assert_difference('User.count', 0) do
      delete :destroy, id: @admin
    end
    assert_difference('User.count', 0) do
      delete :destroy, id: @resident
    end
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can destroy my own user record" do
    sign_in @resident
    assert_difference('User.count', -1) do
      delete :destroy, id: @resident
    end
    assert_response :redirect
    assert_redirected_to users_path
  end

  test "As a resident, I cannot destroy other user records" do
    sign_in @resident
    assert_difference('User.count', 0) do
      delete :destroy, id: users(:resident_1)
    end
    assert_difference('User.count', 0) do
      delete :destroy, id: @admin
    end
    assert_response :redirect
    assert_redirected_to @resident
  end

  test "As an admin, I can destroy my own user record" do
    sign_in @admin
    assert_difference('User.count', -1) do
      delete :destroy, id: @admin
    end
    assert_response :redirect
    assert_redirected_to users_path
  end

  test "As an admin, I can destroy residents that were invited by me" do
    sign_in @admin
    assert_difference('User.count', -1) do
      delete :destroy, id: users(:resident_1)
    end
    assert_response :redirect
    assert_redirected_to users_path
  end

  test "As an admin, I cannot destroy residents that were not invited by me" do
    sign_in @another_residency_admin
    assert_difference('User.count', 0) do
      delete :destroy, id: @resident
    end
    assert_response :redirect
    assert_redirected_to users_path
  end
end
