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
  end

  test "should get index" do
    # As a visitor
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    assert assigns(:users).count == 0
    assert_template :index

    # As a resident
    sign_in @resident
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:users).count > 0
    assert_template :index
    sign_out @resident

    # As an admin
    sign_in @admin
    get :index
    assert_response :success
    assert_not_nil  assigns(:users).count > 0
    assert_template :index
    sign_out @admin
  end

  test "As a visitor, I cannot edit a user" do
    get :edit, id: users(:resident).id
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_template :new
  end


  test "As a resident, I can edit my user record " do
    sign_in @resident
    get :edit, id: users(:resident).id
    assert_response :success
    assert_not_nil assigns(:user)
    assert_template :edit
    sign_out @resident
  end

  test "As a resident, I cannot edit other users" do
    sign_in @resident
    get :edit, id: users(:resident_1).id
    assert_response :redirect
    assert_redirected_to @user
    assert_not_nil assigns(:user)
    assert_template :index
    sign_out @resident
  end

  test "As a visitor, I cannot update other users" do
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_template :new
  end

  test "As a resident, I can update my user record" do
    sign_in @resident
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :success
    sign_out @resident
  end

  test "As a resident, I cannot update another user" do
    sign_in @resident
    # attempt to update a resident
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_template :new

    # attempt to update an admin
    patch :update, id: @admins, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_template :new
    sign_out @resident
  end

  test "As an admin, I can udpate residents that were invited by me" do
    sign_in @admin
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :success
    sign_out @admin
  end

  test "As an admin, I cannot udpate residents that were not invited by my" do
    sign_in @admin
    patch :update, id: @resident, user: { first_name: 'Updated', last_name: 'Updated' }
    assert_response :success
    sign_out @admin
  end

  test "As a visitor, I cannot view a user" do
    # attempt to view a resident
    get :show, id: @resident
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_template :new

    # attempt to view an admin
    get :show, id: @admin
    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert_template :new
  end

  test "As a resident, I can view my user record" do
    sign_in @resident
    get :show, id: @resident
    assert_response :success
    assert_template :show
    sign_out @resident
  end

  test "As a resident, I cannot view other users" do
    # attempt to view another resident
    sign_in @resident
    get :show, id: users(:resident_1)
    assert_response :redirect
    assert_redirected_to @resident
    assert_template :show
    sign_out @resident

    # attempt to view an admin
    sign_in @resident
    get :show, id: @admin
    assert_response :redirect
    assert_redirected_to @resident
    assert_template :show
    sign_out @resident
  end

  test "As an admin, I can view residents that were invited by me" do
    sign_in @admin
    get :show, id: users(:resident_1)
    assert_response :redirect
    assert_redirected_to @admin
    assert_template :show
    sign_out @admin
  end

  test "As an admin, I cannot view residents that were not invited by me" do
    sign_in @admin
    get :show, id: @resident
    assert_response :redirect
    assert_redirected_to @admin
    assert_template :show
    sign_out @admin
  end

  test "As a resident, I cannot destroy users" do
    # attempt to destroy self
    assert_difference('User.count', 0) do
      delete :destroy, id: @resident
    end
    assert_response :redirect
    assert_redirected_to users_path

    # attempt to destroy another residents
    assert_difference('User.count', 0) do
      delete :destroy, id: users(:resident_1)
    end
    assert_response :redirect
    assert_redirected_to users_path

    # attempt to destroy an admin
    assert_difference('User.count', 0) do
      delete :destroy, id: @admin
    end
    assert_response :redirect
    assert_redirected_to users_path
  end

  test "As an admin, I can destroy residents that were invited by me" do
    assert_difference('User.count', -1) do
      delete :destroy, id: users(:resident_1)
    end
    assert_response :success
    assert_redirected_to users_path
  end

  test "As an admin, I cannot destroy residents that were not invited by me" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @resident
    end
    assert_response :redirect
    assert_redirected_to users_path
  end
end
