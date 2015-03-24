require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
    assert_not false
    assert_equal true, true
    assert_not_equal false, true

    assert_not_same users(:resident_0), users(:resident_1)
  end

  test "when a user is destroyed, its encounters are destroyed" do
    users(:resident).destroy!
    assert users(:resident).encounters.count == 0
  end

  test "role" do
    assert users(:resident).role == 'resident'
    assert users(:admin).role == 'admin'
  end

  test "admin?" do
    assert users(:admin).admin?
    assert_not users(:resident).admin?
  end

  test "resident?" do
    assert users(:resident).resident?
    assert_not users(:admin).resident?
  end

  test "subscription expired?" do
    assert_not users(:resident).subscription_expired?
    users(:resident).active_until = Time.now - 1.second
    assert users(:resident).subscription_expired?
  end

  test "days until subscription expiration" do
    assert users(:resident).days_until_subscription_expiration == 1
    assert users(:admin).days_until_subscription_expiration == 6
  end

  test "update invitees active until" do
    users(:admin).update_invitees_active_until
    assert_equal users(:admin).invitations.pluck(:active_until).uniq.size, 1
    assert_includes users(:admin).invitations.pluck(:active_until).uniq, users(:admin).active_until
  end
end
