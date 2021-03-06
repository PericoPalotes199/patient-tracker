class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  add_flash_types :error, :payment

  protected
    # TEST THAT WE CAN SIGNUP AND ACCEPT INVITATION IN THE VIEWS
    # https://github.com/plataformatec/devise/blob/4-0-stable/CHANGELOG.md#400rc1---2016-01-02
    def configure_permitted_parameters
      #allow additional parameters through the Devise::RegistrationsController
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :tos_accepted])

      #allow additional parameters through the Devise::InvitationsController
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [:first_name, :last_name, :tos_accepted])
    end

    def authenticate_inviter!
      # Redirect if the user is not both logged in and an admin
      if !(current_user && current_user.admin?)
        redirect_to new_encounter_path, :alert => 'You are not authorized to invite residents.'
      end
      super
    end

    def after_invite_path_for(resource)
      users_path
    end

    def after_sign_in_path_for(resource)
      if resource.admin?
        users_path
      else # resource.resident? || resource.admin_resident? || (resource has any other role)
        new_encounter_path
      end
    end

    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end

    def log_request
      Rollbar.info("#{controller_name}##{action_name} was requested", user_id: current_user.try(:id))
    end
end
