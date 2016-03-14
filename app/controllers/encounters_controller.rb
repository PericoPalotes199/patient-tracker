class EncountersController < ApplicationController
  include EncountersHelper

  before_action :authenticate_user!
  before_action :set_encounter, only: [:show, :edit, :update, :destroy]
  # GET /encounters
  # GET /encounters.json
  def index
    @encounters = if current_user.admin?
      @encounters = Encounter.includes(:user).where('users.invited_by_id  = ?', current_user.id).references(:users).order(encountered_on: :desc).order('users.name ASC')
    else
      current_user.encounters.order(encountered_on: :desc)
    end
  end

  def summary
    #TODO: Limit this Encounters#summary query to only current_user and current_user's invitations' encounters.
    #TODO: @encounters is needed for the .xls format. Find out if this can be defined only for the .xls format.
    @encounters = Encounter.all.includes(:user).order(encountered_on: :desc).order('users.name ASC')

    #TODO: Map encounter_type values to an integer so that reults can be ordered
    #TODO: identical to encounters/new view
    @encounters_count = Encounter.group(:user_id, :encounter_type).order(:user_id, :encounter_type).count

    respond_to do |format|
      format.html
      format.xls
    end
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
      ActiveRecord::Base.transaction do
        encounter_params.each do |encounter_type, number|
          total += number.to_i
          number.to_i.times {
            Encounter.create!(
              encounter_type: encounter_type.gsub('_', ' '),
              encountered_on: params[:encountered_on],
              user: current_user
            )
          }
        end
      end
    rescue ActiveRecord::ActiveRecordError => error
      STDERR.puts "Error in EncountersController#create: #{error.message}"
      redirect_to :new_encounter, alert: "Something went wrong!
                      Your encounters were not counted!
                      Please count again!"
    else
      if total.zero?
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def encounter_params
      params.require(:encounter_types).permit( encounter_types )
    end

    # Require that params[:encountered_on] is not empty and return the value
    def encountered_on
      params.require :encountered_on
    end
end
