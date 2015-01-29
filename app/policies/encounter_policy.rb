class EncounterPolicy < ApplicationPolicy
  attr_reader :user, :encounter

  def initialize(user, encounter)
    @user = user
    @encounter = encounter
  end

  def index?
    # the encounter belongs to the current_user or
    user.id == encounter.user.id ||
    # the current_user is an admin who invited the user who created the encounter or
    ( user.role == 'admin' && user.id == encounter.user.invited_by_id ) ||
    # the current_user is an admin within the same residency
    ( user.role == 'admin' && user.residency == encounter.user.residency )
  end

  def show?
    # No need to show an individual encounter unless the user is the creator.
    # The encounters/show view is primarily used to access the destroy button.
    user.id == encounter.user.id
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
