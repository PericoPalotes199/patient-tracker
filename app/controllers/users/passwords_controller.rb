class Users::PasswordsController < Devise::PasswordsController

  # PUT /users/password
  def update
    tos_accepted = resource_params[:tos_accepted]

    self.resource = User.find_by(resource_params[:email])
    if tos_accepted == "1"
      resource.tos_accepted = tos_accepted
      resource.save
      super
    else
      respond_with resource, location: edit_user_password_path(reset_password_token: resource_params[:reset_password_token])
    end
  end
end
