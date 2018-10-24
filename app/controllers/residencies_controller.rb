class ResidenciesController < ApplicationController
  before_action :set_residency, only: [:show, :edit, :update, :destroy]

  # GET /residencies
  # GET /residencies.json
  def index
    @residencies = Residency.all
  end

  # GET /residencies/1
  # GET /residencies/1.json
  def show
  end

  # GET /residencies/new
  def new
    @residency = Residency.new
  end

  # GET /residencies/1/edit
  def edit
  end

  # POST /residencies
  # POST /residencies.json
  def create
    @residency = Residency.new(residency_params)

    respond_to do |format|
      if @residency.save
        format.html { redirect_to @residency, notice: 'Residency was successfully created.' }
        format.json { render :show, status: :created, location: @residency }
      else
        format.html { render :new }
        format.json { render json: @residency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /residencies/1
  # PATCH/PUT /residencies/1.json
  def update
    respond_to do |format|
      if @residency.update(residency_params)
        format.html { redirect_to @residency, notice: 'Residency was successfully updated.' }
        format.json { render :show, status: :ok, location: @residency }
      else
        format.html { render :edit }
        format.json { render json: @residency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /residencies/1
  # DELETE /residencies/1.json
  def destroy
    @residency.destroy
    respond_to do |format|
      format.html { redirect_to residencies_url, notice: 'Residency was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_residency
      @residency = Residency.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def residency_params
      params.require(:residency).permit(:name)
    end
end
