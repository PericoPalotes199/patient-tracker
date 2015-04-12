class Users::PasswordsController < Devise::PasswordsController

  # PUT /users/password
  def update
    super do |resource|
      resource.tos_accepted = resource_params[:tos_accepted]
      resource.save
    end
  end
end
