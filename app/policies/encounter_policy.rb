class EncounterPolicy < ApplicationPolicy
  attr_reader :user, :encounter

  def initialize(user, encounter)
    @user = user
    @encounter = encounter
  end

  def index?
    user.id == encounter.user.id || user.role == 'Admin'
  end

  def show?
    index?
  end

  def new?
    create?
  end

  def create?
    user.role == 'Resident'
  end

  def edit?
    update?
  end

  def update?
    user.role == 'Resident' && user.id == encounter.user.id
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
