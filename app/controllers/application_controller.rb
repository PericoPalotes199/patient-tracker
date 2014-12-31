class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  add_flash_types :error, :payment

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name]
    end

    def authenticate_inviter!
      unless current_user.role == 'admin'
        redirect_to root_url, :alert => 'You are not authorized to invite resdients.'
      end
      super
    end
end
