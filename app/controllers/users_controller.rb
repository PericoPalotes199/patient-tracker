class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    # the two-query implementation needs to remain until
    # residents are assigned a residency on invitation

    if current_user
      @users = current_user.invitations.to_a
      # TODO: create a Residency resource and association
      # get all users of the current_user residency
      residency_users = User.where(residency: current_user.residency)

      residency_users.each do |user|
        # filtering on current_user allows adding an explicit top row for current_user in view
        @users << user unless @users.include?(user) || user == current_user
      end
    else #!current_user
      @users = User.none
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    set_user
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name)
    end
end
