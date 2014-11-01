class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  # GET /patients
  # GET /patients.json
  def index
    @patients = Patient.all.includes(:user).order(encountered_on: :desc).order('users.name ASC')
  end

  def summary
    @patients = Patient.all.includes(:user).order(encountered_on: :desc).order('users.name ASC')

    #TODO: Map encounter_type values to an integer so that reults can be ordered
    #identical to patients/new view
    @patients_count = Patient.group(:user_id, :encounter_type).order(:user_id, :encounter_type).count

    respond_to do |format|
      format.html
      format.xls
    end
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
  end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients
  # POST /patients.json
  def create

    total = 0
    begin
      ActiveRecord::Base.transaction do
        encounter_types.each do |type, number|
          total += number.to_i
          number.to_i.times {Patient.create!(encounter_type: type.to_s.humanize(capitalize: false), encountered_on: encountered_on, user: current_user)}
        end
      end
    rescue ActiveRecord::ActiveRecordError => error
      STDERR.puts "Error in PatientsController#create: #{error.message}"
      redirect_to :new_patient, alert: "Something went wrong!
                      Your encounters were not counted!
                      Please count again!"
    else
      if total == 0
        redirect_to :new_patient, alert: 'You did not count your encounters!'
      else
        redirect_to :patients, notice: 'Your encounters have been counted!'
      end
    end
  end

  # PATCH/PUT /patients/1
  # PATCH/PUT /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to patients_url, notice: 'Patient was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_params
      params.require(:patient).permit(:encounter_type)
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
