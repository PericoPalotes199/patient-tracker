require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  def setup
    @item = Item.all.sample
  end

  test "the name is the same as the underscored label" do
    assert_equal @item.label.remove(' ').underscore, @item.name
  end
end
