class Users::PasswordsController < Devise::PasswordsController

  # PUT /users/password
  def update
    tos_accepted = resource_params[:tos_accepted]

    # found in devise-invitable's #reset_password_by_token method
    original_token       = resource_params[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
    # find *without* initializing with an error
    self.resource = User.find_by(reset_password_token: reset_password_token)

    if tos_accepted == "1"
      resource.tos_accepted = tos_accepted
      resource.save
      super
    else
      flash[:alert] = 'Terms of service must be accepted.'
      respond_with resource,
        location: edit_user_password_path(reset_password_token: resource_params[:reset_password_token])
    end
  end
end
