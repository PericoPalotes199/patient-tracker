class EncounterPolicy < ApplicationPolicy
  attr_reader :user, :encounter

  def initialize(user, encounter)
    @user = user
    @encounter = encounter
  end

  def index?
    # the encounter belongs to the current_user or
    user.id == encounter.user.id ||
    # the current_user is an admin or admin_residet and is the user
    # who invited the user who created the encounter or
    ( (user.admin? || user.admin_resident?) && user.id == encounter.user.invited_by_id )
    # TOOD: the current_user is an admin or admin_resident within the same residency
    # TODO: This was previously implmented, but not with a performant query.
    # TODO: Going forward, a residency model should be added to enable
    # TODO: more flexible management of the data and more performant queries.
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
    user.resident? || user.admin? || user.admin_resident?
  end

  def edit?
    update?
  end

  def update?
    user.resident? && user.id == encounter.user.id
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
