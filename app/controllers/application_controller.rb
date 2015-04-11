class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  add_flash_types :error, :payment

  protected
    def configure_permitted_parameters
      #allow additional parameters through the Devise::RegistrationsController
      devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name, :tos_accepted]

      #allow additional parameters through the Devise::InvitationsController
      devise_parameter_sanitizer.for(:accept_invitation) << [:first_name, :last_name, :tos_accepted]
    end

    def authenticate_inviter!
      unless current_user.role == 'admin'
        redirect_to users_path, :alert => 'You are not authorized to invite residents.'
      end
      super
    end

    def after_invite_path_for(resource)
      users_path
    end

    def after_sign_in_path_for(resource)
      if resource.admin?
        users_path
      elsif resource.resident?
        new_encounter_path
      else # resource.admin_resident?
        super
      end
    end

    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end
end
