class UserPolicy < ApplicationPolicy
  attr_reader :user, :scope

  def index?
    # this policy is used in the users/index view
    # the displayed users are limited with
    # where conditions in the controller's queries
    user.admin?
  end

  def show?
    # current_user is the user in question or
    user == record ||
    # current_user is an admin who invited the user in question
    ( user.admin? && record.invited_by_id == user.id ) ||
    # current_user is an admin within the same residency
    ( user.admin? && user.residency == record.residency ) ||
    # current_user is an admin_resident within the same residency
    ( user.admin_resident? && user.residency == record.residency )
  end

  def edit?
    user == record
  end

  def invite?
    user.admin?
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
