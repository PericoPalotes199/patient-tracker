class EncountersController < ApplicationController

  before_action :authenticate_user!
  before_action :set_encounter, only: [:show, :edit, :update, :destroy]

  # GET /encounters
  # GET /encounters.json
  def index
    set_encounters
  end

  def summary
    #TODO: Map encounter_type values to an integer so that reults can be ordered
    #TODO: identical to encounters/new view
    set_encounters

    # @encounters could be an array, so re-query the encounters and group them
    # TODO: If this proves to be non-performant, support for admin_resident should
    # be dropped until a residency model and association is implemented
    @grouped_encounters = Encounter.
      where(id: @encounters.map(&:id)).
      group(:user_id, :encounter_type).
      order(:user_id, :encounter_type).
      count

    respond_to :html, :xls
  end

  # GET /encounters/1
  # GET /encounters/1.json
  def show
    if current_user.admin? || !current_user.eql?(@encounter.user)
      redirect_to encounters_path and return
    end
  end

  # GET /encounters/new
  def new
    @encounter = Encounter.new
  end

  # POST /encounters
  # POST /encounters.json
  def create
    redirect_to(encounters_path, notice: 'You cannot create encounters!') and return if current_user.admin?
    total = 0
    begin
      Encounter.transaction do
        encounter_params.each do |type, number|
          total += number.to_i
          number.to_i.times {
            Encounter.create!(
              encounter_type: type.to_s.humanize(capitalize: false),
              encountered_on: encountered_on,
              user: current_user
            )
          }
        end
      end
    rescue ActiveRecord::ActiveRecordError => error
      STDERR.puts "Error in EncountersController#create: #{error.message}" if Rails.env.development?
      Rollbar.warning 'Caught ActiveRecordError', error.message
      redirect_to :new_encounter, alert: "Something went wrong!
                      Your encounters were not counted!
                      Please count again!"
    else
      if total == 0
        redirect_to :new_encounter, alert: 'You did not count your encounters!'
      else
        redirect_to :encounters, notice: 'Your encounters have been counted!'
      end
    end
  end

  # DELETE /encounters/1
  # DELETE /encounters/1.json
  def destroy
    if current_user.eql?(@encounter.user)
      @encounter.destroy
    end
    redirect_to encounters_url, notice: 'Encounter was successfully deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_encounter
      @encounter = Encounter.find(params[:id])
    end


    # The query should include
    # 1. the encounters of the current user (current_user.encounters)
    # 2. the encounters of the admin's invitations (current_user.invitations.map(&:encounters).flatten)
    # 3. or both (in the case of an admin_resident)
    def set_encounters
      if current_user.admin?
        @encounters = encounters_for_admin
      elsif current_user.admin_resident?
        @encounters = encounters_for_admin_resident
      elsif current_user.resident?
        @encounters = encounters_for_resident
      else
        @encounters = Encounter.none
      end
    end

    def encounters_for_admin
      Encounter.includes(:user).
        where('users.invited_by_id = ?', current_user.id).
        references(:users).
        order(encountered_on: :desc).
        order('users.name ASC')
    end

    def encounters_for_admin_resident
      [encounters_for_admin, encounters_for_resident].flatten
    end

    def encounters_for_resident
      current_user.encounters.order(encountered_on: :desc)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def encounter_params
      params.require(:encounter_types).permit(Encounter.encounter_types.map{|str| str.to_sym})
    end

    # Require that params[:encountered_on] is not empty and return the value
    def encountered_on
      params.require(:encountered_on)
    end
end
