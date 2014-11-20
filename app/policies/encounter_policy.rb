class EncounterPolicy < ApplicationPolicy
  attr_reader :user, :encounter

  def initialize(user, encounter)
    @user = user
    @encounter = encounter
  end

  def summary?
    user.role == 'Admin' || user.role == 'admin'
  end

  def index?
    user.id == encounter.user.id || user.role == 'Admin' || user.role == 'admin'
  end

  def show?
    index?
  end

  def new?
    create?
  end

  def create?
    user.role == 'Resident' || user.role == 'resident'
  end

  def edit?
    update?
  end

  def update?
    (user.role == 'Resident' || user.role == 'resident') && user.id == encounter.user.id
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
