class UsersRegistrationsControllerTest < ActionController::TestCase

  setup do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @controller = Users::RegistrationsController.new
  end

  #  If you are testing Devise internal controllers or a controller that inherits from Devise's,
  #  you need to tell Devise which mapping should be used before a request.
  #  This is necessary because Devise gets this information from the router,
  #  but since functional tests do not pass through the router, it needs to
  #  be stated explicitly. For example, if you are testing the user scope, simply use:
  #  @request.env["devise.mapping"] = Devise.mappings[:user]
  #  get :new

  test "Registering without a residency renders the new registration view without creating a user." do
    assert_no_difference('User.count') {
      post :create, user: { email: 'test@example.com', password: 'password', password_confirmation: 'password', tos_accepted: '1' }
    }
    assert_response :redirect
    assert_redirected_to new_user_registration_url
    assert_nil User.find_by email: 'test@example.com'
  end

  test "Registering a new user creates a user and redirects to users#index." do
    assert_difference('User.count', 1) {
      post :create, user: { residency_name: 'Test Registration Residency', email: 'test@example.com', password: 'password', password_confirmation: 'password', tos_accepted: '1' }
    }
    assert_not_nil User.find_by email: 'test@example.com'
    assert_template 'devise/mailer/confirmation_instructions'
    assert_response :redirect
    assert_redirected_to new_user_registration_url
  end

  test "Registering a new user creates an admin and a residency." do
    assert_difference("User.where(role: 'admin').count", 1) {
      post :create, user: { residency_name: 'Test Registration Residency', email: 'test@example.com', password: 'password', password_confirmation: 'password', tos_accepted: '1' }
    }
    new_admin_user = User.find_by!(
      role: 'admin',
      residency_name: 'Test Registration Residency',
      residency: Residency.find_by!(name: 'Test Registration Residency')
    )
    assert_equal User.last, new_admin_user
    assert_equal Residency.last, Residency.find_by!(name: 'Test Registration Residency')
  end
end
