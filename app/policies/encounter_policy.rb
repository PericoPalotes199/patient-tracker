class EncounterPolicy < ApplicationPolicy
  attr_reader :user, :encounter

  def initialize(user, encounter)
    @user = user
    @encounter = encounter
  end

  def summary?
    user.role == 'admin'
  end

  def index?
    user.id == encounter.user.id || user.role == 'admin'
  end

  def show?
    index?
  end

  def new?
    create?
  end

  def create?
    user.role == 'resident' || user.role == 'admin'
  end

  def edit?
    update?
  end

  def update?
    user.role == 'resident' && user.id == encounter.user.id
  end

  def destroy?
    user.id == encounter.user.id
  end

  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
end
