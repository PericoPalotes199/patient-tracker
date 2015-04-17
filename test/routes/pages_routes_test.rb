class PagesRoutesTest < ActionController::TestCase

  # RUN: rake test test/routes/*

  test "should get faq page" do
    assert_routing({ method: 'get', path: '/faq'}, {controller: 'pages', action: 'faq' })
  end

  test "should get home page" do
    assert_routing({ method: 'get', path: '/'}, {controller: 'pages', action: 'index' })
  end

end
