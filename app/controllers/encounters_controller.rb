class EncountersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_encounter, only: [:show, :edit, :update, :destroy]
  # GET /encounters
  # GET /encounters.json
  def index
    #TODO: Limit this Encounters#index query to only current_user and current_user's invitations' encounters.
    #TODO: No need to loop through every encounter in the view!
    @encounters = Encounter.all.includes(:user).order(encountered_on: :desc).order('users.name ASC')
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

    total = 0
    begin
      ActiveRecord::Base.transaction do
        encounter_types.each do |type, number|
          total += number.to_i
          number.to_i.times {Encounter.create!(encounter_type: type.to_s.humanize(capitalize: false), encountered_on: encountered_on, user: current_user)}
        end
      end
    rescue ActiveRecord::ActiveRecordError => error
      STDERR.puts "Error in EncountersController#create: #{error.message}"
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
    @encounter.destroy
    respond_to do |format|
      format.html { redirect_to encounters_url, notice: 'Encounter was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_encounter
      @encounter = Encounter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def encounter_params
      params.require(:encounter).permit(:encounter_type)
    end

    # Require that params[:encountered_on] is not empty and return the value
    def encountered_on
      params.require(:encountered_on)
    end

    def encounter_types
      params.require(:encounter_types).permit(
        :adult_inpatient, :adult_ed, :adult_icu, :adult_inpatient_surgery,
        :pediatric_inpatient, :pediatric_newborn, :pediatric_ed,
        :continuity_inpatient, :continuity_external
      )
    end
end
