class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    # the two-query implementation needs to remain until
    # residents are assigned a residency on invitation

    @users = current_user.invitations.to_a
    # TODO: create a Residency resource and association
    # get all users of the current_user residency
    residency_users = User.where(residency: current_user.residency)

    residency_users.each do |user|
      # filtering on current_user allows adding an explicit top row for current_user in view
      @users << user unless @users.include?(user) || user == current_user
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if !( current_user.admin? && current_user.invitations.include?(@user) || current_user.eql?(@user) )
      redirect_to current_user
    end
  end

  # GET /users/1/edit
  def edit
    if !( current_user.admin? && current_user.invitations.include?(@user) || current_user.eql?(@user) )
      if current_user.admin?
        redirect_to users_path
      else
        redirect_to current_user
      end
    end
  end

  # PATCH/PUT /users/1
  def update
    if current_user.admin? && current_user.invitations.include?(@user) || current_user.eql?(@user)
      if @user.update(user_params)
        redirect_to @user, notice: 'User was successfully updated.'
      else
        render :edit
      end
    else # current_user is not @user and current_user did not invite @user
      if current_user.admin?
        redirect_to users_url, notice: "You can't destroy that user."
      else
        redirect_to current_user, notice: "You can't destroy that user."
      end
    end
  end

  # DELETE /users/1
  def destroy
    if current_user.admin? && current_user.invitations.include?(@user) || current_user.eql?(@user)
      if @user.destroy
        redirect_to users_url, notice: 'User was successfully destroyed.'
      else
        puts @user.errors.messages
        render @user
      end
    else # current_user is not @user and current_user did not invite @user
      if current_user.admin?
        redirect_to users_url, notice: "You can't destroy that user."
      else
        redirect_to current_user, notice: "You can't destroy that user."
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      keys = [:email, :first_name, :last_name]
      keys << :tos_accepted if current_user.eql?(@user)
      params.require(:user).permit(keys)
    end
end
