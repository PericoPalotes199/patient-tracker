require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  def setup
    @items = Item.all
  end

  test "the name is the same as the underscored label" do
    assert_equal @items.map { |item| item.label.gsub!(/[^a-z0-9]/i, '').underscore }, @items.pluck(:name)
  end
end
