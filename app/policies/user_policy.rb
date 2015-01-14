class UserPolicy < ApplicationPolicy
  attr_reader :user, :scope

  def index?
    user.admin?
  end

  def show?
    user == record || user.admin?
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
