class Users::PasswordsController < Devise::PasswordsController

  # PUT /users/password
  def update
    tos_accepted = resource_params[:tos_accepted]

    if tos_accepted != "1"
      flash[:alert] = 'Terms of service must be accepted.'
      respond_with(resource, location: edit_user_password_path(resource_params.slice(:reset_password_token))) and return
    end

    if resource_params[:password] != resource_params[:password_confirmation]
      flash[:alert] = 'Passwords must match.'
      respond_with(resource, location: edit_user_password_path(resource_params.slice(:reset_password_token))) and return
    end

    # Continue with Devise default functionality
    # https://github.com/plataformatec/devise/blob/v3.5.10/app/controllers/devise/passwords_controller.rb#L35
    super do
      resource.tos_accepted = tos_accepted
      resource.save
    end

  end
end
