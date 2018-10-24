require 'test_helper'

class ResidencyTest < ActiveSupport::TestCase
  test "a valid residency" do
    assert_same residencies(:valid_residency).valid?, true
  end

  test "name is required" do
    residency = Residency.new(name: nil)
    assert_same(residency.valid?, false)
    assert_equal(residency.errors.messages.first, [:name, ["can't be blank"]])
  end
end
