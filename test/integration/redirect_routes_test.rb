require 'test_helper'

class RedirectRoutesTest < ActionDispatch::IntegrationTest
  test "/users/new should redirect to new user registration" do
    # If the user is trying to use the new user URL, re-direct them to sign-up,
    # which will also re-direct if they are already signed in.
    get '/users/new'
    assert_redirected_to '/users/sign_up'
    follow_redirect!
    assert_response :success
  end

  test "/users/sign_out should redirect to users sign in" do
    # This prevents re-submit of the invitation URL and redirect the user
    # to the login-page, considering that the most likely reason
    # the user attempts GET /users/sign_out is because they are reloading
    # the page after having signed out.
    get '/users/sign_out'
    assert_redirected_to '/users/sign_in'
    follow_redirect!
    assert_response :success
  end

  test "/users/invitation redirect to users index" do
    # This prevents re-submit of the invitation URL and redirects the user to somewhere more useful
    get '/users/invitation'
    assert_redirected_to '/users'
    follow_redirect!
    # Since this test does not have a signed-in user, another redirect occurs
    assert_redirected_to '/users/sign_in'
    follow_redirect!
    assert_response :success
  end
end
