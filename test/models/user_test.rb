require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @admin = users(:admin)
    @minimum_valid_resident_attributes = {
      role: 'resident',
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password',
      tos_accepted: true
    }
    @minimum_valid_admin_attributes = {
      role: 'admin',
      email: 'test@example.com',
      residency: residencies(:test_residency),
      password: 'password',
      password_confirmation: 'password',
      tos_accepted: true
    }
  end

  test "some simple assertions to confirm configuration is valid" do
    assert true
    assert_not false
    assert_equal true, true
    assert_not_equal false, true

    assert_not_same users(:resident_0), users(:resident_1)
  end

  test "the encounters fixtures are loading" do
    assert_equal 54, users(:resident).encounters.count
    assert_equal 45, users(:resident_1).encounters.count
  end

  test "users are related like a typical residency" do
    assert_equal nil, users(:admin_resident).invited_by
    assert_equal @admin, users(:resident).invited_by
    assert_equal @admin, users(:resident_1).invited_by
  end

  test "#valid?" do
    assert_equal User.new(@minimum_valid_resident_attributes).valid?, true
    assert_equal User.new(@minimum_valid_resident_attributes.merge(residency: nil)).valid?, true
    assert_equal User.new(@minimum_valid_resident_attributes.merge(residency: nil, invitation_accepted_at: Time.now)).valid?, false

    assert_equal User.new(@minimum_valid_admin_attributes).valid?, true
    assert_equal User.new(@minimum_valid_admin_attributes.merge(residency: nil)).valid?, false
  end

  test "when a user is saved, its name is updated" do
    users(:resident).update first_name: 'Updated', last_name: 'Resident', tos_accepted: true
    assert users(:resident).name, 'Updated Resident'
  end

  test "when a user is destroyed, its encounters are NOT destroyed" do
    encounters_count = users(:resident).encounters.count
    users(:resident).destroy!
    assert users(:resident).encounters.count == encounters_count
  end

  test "role" do
    assert users(:resident).role == 'resident'
    assert users(:admin).role == 'admin'
    assert users(:admin_resident).role == 'admin_resident'
  end

  test "admin?" do
    assert     users(:admin).admin?
    assert_not users(:admin).admin_resident?
    assert_not users(:admin).resident?
  end

  test "admin_resident?" do
    assert_not users(:admin_resident).admin?
    assert     users(:admin_resident).admin_resident?
    assert_not users(:admin_resident).resident?
  end

  test "resident?" do
    assert_not users(:resident).admin?
    assert_not users(:resident).admin_resident?
    assert     users(:resident).resident?
  end

  test "has_custom_labels?" do
    # NOTE: Always returns false, until custom labels feature is implemented
    assert_not users(:admin).has_custom_labels?
    assert_not users(:admin_resident).has_custom_labels?
    assert_not users(:resident).has_custom_labels?
  end

  test "subscription expired?" do
    assert_not users(:resident).subscription_expired?
    users(:resident).active_until = Time.now - 1.second
    assert users(:resident).subscription_expired?
    users(:resident).active_until = nil
    assert users(:resident).subscription_expired?
  end

  test "days until subscription expiration" do
    assert users(:resident).days_until_subscription_expiration == 1
    assert users(:admin).days_until_subscription_expiration == 6
  end

  test "an admin can invite a resident" do
    resident = User.invite!({ email: 'invited-resident@example.com' }, @admin)
    assert_equal resident.invited_by, @admin
  end

  test "when an admin invites a user, their role will be resident" do
    resident = User.invite!({ email: 'invited-resident@example.com' }, @admin)
    assert_equal resident.role, 'resident'
  end

  test "when an admin invites a resident, the resident will have the same residency" do
    skip "Upgrade devise_invitable to use after_invitation_created callback"
    resident = User.invite!({ email: 'invited-resident@example.com' }, @admin)
    assert_equal @admin.residency.name, resident.residency.name
    assert_equal @admin.residency, resident.residency
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

  test "when a user accepts an invitation, they should no longer have Stripe subscriptions" do
    skip('User invitations must be equal to Stripe subscription quantity!')
    assert users(:admin).invitations.count <
           Stripe::Customer.retrieve('cus_0000000').subscriptions.first.quantity
    User.accept_invitation!(invitation_token: users(:unconfirmed).invitation_token)
    assert Stripe::Customer.retrieve(users(:unconfirmed).customer_id).subscriptions.length, 0
  end

  test "when a user accepts an invitation, then change role to resident" do
    admin = User.create!(
      email: 'admin-to-resident@example.com',
      password: 'password',
      role: 'admin',
      residency: residencies(:test_residency),
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

  test "when a user accepts an invitation set residency to inviter's residency" do
    resident = User.invite!({email: 'invited-resident@example.com'}, users(:admin))
    resident = User.accept_invitation!(
      invitation_token: resident.raw_invitation_token,
      password: 'password',
      password_confirmation: 'password',
      tos_accepted: true)
    assert_equal 'Test Residency', resident.residency.name
    assert_equal users(:admin).residency, resident.residency
  end

  test "when a user accepts an invitation set active_until to inviter's active_until" do
    resident = User.invite!({email: 'invited-resident@example.com'}, users(:admin))
    resident = User.accept_invitation!(
      invitation_token: resident.raw_invitation_token,
      password: 'password',
      password_confirmation: 'password',
      tos_accepted: true)
    assert_not_nil users(:admin).active_until
    assert_equal users(:admin).active_until, resident.active_until
  end
end
