class EncountersRoutesTest < ActionController::TestCase

  # RUN: rake test test/routes/*

  test "should route to encounters summary" do
    assert_routing({ method: 'get', path: '/encounters/summary' }, { controller: 'encounters', action: 'summary' })
  end

  test "should route to encounters index" do
    assert_routing({ method: 'get', path: '/encounters' }, { controller: 'encounters', action: 'index' })
  end

  test "should route to encounters show" do
    assert_routing({ method: 'get', path: '/encounters/1' }, { controller: 'encounters', action: 'show', id: '1' })
  end

  test "should route to encounters new" do
    assert_routing({ method: 'get', path: '/encounters/new' }, { controller: 'encounters', action: 'new' })
  end

  test "should route to encounters create" do
    assert_routing({ method: 'post', path: '/encounters' }, { controller: 'encounters', action: 'create' })
  end

  test "should route to encounters edit" do
    assert_routing({ method: 'get', path: '/encounters/1/edit' }, { controller: 'encounters', action: 'edit', id: '1' })
  end

  test "should route to encounters update" do
    assert_routing({ method: 'patch', path: '/encounters/1' }, { controller: 'encounters', action: 'update', id: '1' })
  end

  test "should route to encounters destroy" do
    assert_routing({ method: 'delete', path: '/encounters/1' }, { controller: 'encounters', action: 'destroy', id: '1' })
  end

end
