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
    ( (user.admin? || user.admin_resident?) && record.invited_by_id == user.id )
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
