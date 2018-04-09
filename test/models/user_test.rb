require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @admin = users(:admin)
  end

  test "the truth" do
    assert true
    assert_not false
    assert_equal true, true
    assert_not_equal false, true

    assert_not_same users(:resident_0), users(:resident_1)
  end

  test "when a user is destroyed, its encounters are NOT destroyed" do
    encounters_count = users(:resident).encounters.count
    users(:resident).destroy!
    assert users(:resident).encounters.count == encounters_count
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
    assert_equal 1, users(:admin).invitations.pluck(:active_until).uniq.size
    assert_equal users(:admin).active_until, users(:admin).invitations.pluck(:active_until).uniq.first
  end

  test "when a user accepts an invitation, the inviter subscription quantity is updated" do
    skip('User invitations must be equal to Stripe subscription quantity!')
    assert users(:admin).invitations.count <
           Stripe::Customer.retrieve('cus_0000000').subscriptions.first.quantity
    User.accept_invitation!(invitation_token: users(:unconfirmed).invitation_token)
    assert users(:admin).invitations.count ==
           Stripe::Customer.retrieve('cus_0000000').subscriptions.first.quantity
  end

  test "when a user accepts an invitation, then change role to resident" do
    admin = User.create!(
      email: 'admin-to-resident@example.com',
      password: 'password',
      role: 'admin',
      residency: 'Test Residency',
      tos_accepted: true)
    assert_equal 'admin', admin.role
    admin.invite!
    assert_not_nil admin.invitation_token
    assert_not_nil admin.raw_invitation_token
    assert_not_nil admin.invitation_created_at
    admin = User.accept_invitation!(
      invitation_token: admin.raw_invitation_token,
      password: 'password',
      password_confirmation: 'password')
    assert_equal 'admin-to-resident@example.com', admin.email
    assert_equal 'resident', admin.role
  end

  test "when a user accepts an invitation set residency to inviter s residency" do
    resident = User.invite!({email: 'invited-resident@example.com'}, users(:admin))
    resident = User.accept_invitation!(
      invitation_token: resident.raw_invitation_token,
      password: 'password',
      password_confirmation: 'password',
      tos_accepted: true)
    assert_equal 'Test Residency', resident.residency
  end
end
