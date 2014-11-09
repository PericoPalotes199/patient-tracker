class UserPolicy < ApplicationPolicy
  attr_reader :user, :scope

  def index?
    admin?
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
