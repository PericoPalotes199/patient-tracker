class UsersPasswordsControllerTest < ActionController::TestCase

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @controller = Users::PasswordsController.new
    @resident = users(:forgetful_resident)

    # Reset the password with the public method and get the token for edit password form
    # https://github.com/plataformatec/devise/blob/v3.5.10/lib/devise/models/recoverable.rb#L58
    @reset_token = @resident.send_reset_password_instructions
  end

  #  If you are testing Devise internal controllers or a controller that inherits from Devise's,
  #  you need to tell Devise which mapping should be used before a request.
  #  This is necessary because Devise gets this information from the router,
  #  but since functional tests do not pass through the router, it needs to
  #  be stated explicitly. For example, if you are testing the user scope, simply use:
  #  @request.env["devise.mapping"] = Devise.mappings[:user]
  #  get :new

  test "passwords can be edited" do
    get :edit, reset_password_token: 'invalid-reset-password-token'
    assert_response :success
    assert_template :edit
  end

  test "get password edit form with empty token redirects" do
    get :edit, reset_password_token: ''
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "password can be updated if tos accepted" do
    put :update, user: { reset_password_token: @reset_token, password: 'new-password', password_confirmation: 'new-password', tos_accepted: '1' }
    assert User.find_by(email: 'forgetful@example.com').valid_password?('new-password')
    assert_not User.find_by(email: 'forgetful@example.com').valid_password?('old-password')
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "password cannot be updated if tos not accepted" do
    put :update, user: { reset_password_token: @reset_token, password: 'new-password', password_confirmation: 'new-password', tos_accepted: '0' }
    @resident.reload
    assert_equal @resident.errors.count, 0
    assert_equal users(:forgetful_resident).encrypted_password, 'old-password'
    assert_equal 'Terms of service must be accepted.', flash[:alert]
    assert_response :redirect
    assert_redirected_to edit_user_password_path(reset_password_token: @reset_token)
  end
end
