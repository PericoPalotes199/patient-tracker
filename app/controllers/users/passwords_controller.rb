class Users::RegistrationsController < Devise::RegistrationsController

  # PUT /users/password
  def update
    super do |resource|
      resource.tos_accepted = resource_params[:tos_accepted]
    end
  end
end
