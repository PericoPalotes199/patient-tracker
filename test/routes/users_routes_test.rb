class UsersRoutesTest < ActionController::TestCase

  # RUN: rake test test/routes/*

  test "should route to devise users sessions new" do
    assert_routing( {method: 'get', path: '/users/sign_in'}, {controller: 'users/sessions', action: 'new' })
  end

  test "should route to devise users sessions create" do
    assert_routing( {method: 'post', path: '/users/sign_in'}, {controller: 'users/sessions', action: 'create' })
  end

  test "should route to devise users sessions destroy" do
    assert_routing( {method: 'delete', path: '/users/sign_out'}, {controller: 'users/sessions', action: 'destroy' })
  end

  test "should route to devise users registrations new" do
    assert_routing( {method: 'get', path: '/users/sign_up'}, {controller: 'users/registrations', action: 'new' })
  end

  test "should route to devise users registrations create" do
    assert_routing( {method: 'post', path: '/users'}, {controller: 'users/registrations', action: 'create' })
  end

  test "should route to users registrations payment info" do
    assert_routing({ method: 'get', path: '/payment_info'}, {controller: 'users/registrations', action: 'payment_info' })
  end

  test "should route to users registrations pay" do
    assert_routing({ method: 'post', path: '/pay'}, {controller: 'users/registrations', action: 'pay' })
  end

  test "should route to users index" do
    assert_routing({ method: 'get', path: '/users' }, { controller: 'users', action: 'index' })
  end

  test "should route to users show" do
    assert_routing({ method: 'get', path: '/users/1' }, { controller: 'users', action: 'show', id: '1' })
  end

  test "should route to users edit" do
    assert_routing({ method: 'get', path: '/users/1/edit' }, { controller: 'users', action: 'edit', id: '1' })
  end

  test "should route to users update" do
    assert_routing({ method: 'patch', path: '/users/1' }, { controller: 'users', action: 'update', id: '1'})
  end

  test "should route to users destroy" do
    assert_routing({ method: 'delete', path: '/users/1' }, { controller: 'users', action: 'destroy', id: '1' })
  end

end
