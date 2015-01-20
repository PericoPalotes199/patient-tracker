class Users::RegistrationsController < Devise::RegistrationsController

  # GET /payment_info
  def payment_info
    @user = current_user
  end

  # POST /pay
  def pay
    begin
      @user = current_user
      customer = Stripe::Customer.retrieve(@user.customer_id)
      customer.card = params[:stripeToken]
      customer.save
      subscription = customer.subscriptions.first
      subscription.plan = params[:plan]
      subscription.quantity = @user.invitations.invitation_accepted.count + 1
      if subscription.save
        #TODO: This should probably be an ActiveRecord callback.
        save_active_until(@user, subscription.current_period_end)
        flash[:success] = "Thank you for updating your payment info!"
        Rails.logger.info "Succesfully updated customer card!"
        redirect_to users_path and return
      else
        flash[:error] = 'Please try again!'
        render :payment_info and return
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      flash[:payment] = "Payment unsuccessful."
      #TODO: send an e-mail to application owner
      Rails.logger.error "Payment unsuccessful: #{e.message}"
      redirect_to payment_info_path and return
    rescue Stripe::StripeError => e
      flash[:error] = e.message
      flash[:payment] = "Payment unsuccessful."
      #TODO: send an e-mail to application owner
      Rails.logger.error "Payment unsuccessful: #{e.message}"
      redirect_to payment_info_path and return
    rescue StandardError => e
      flash[:error] = "There was a problem! Please try again.\nIf the problem persists please contact us at #{ENV["CONTACT_EMAIL_ADDRESS"]}."
      flash[:payment] = "Payment unsuccessful."
      #TODO: send an e-mail to application owner
      Rails.logger.error "Payment unsuccessful: #{e.message}"
      redirect_to payment_info_path and return
    end
  end

  # GET /users/sign_up
  def new
    flash.now.alert = 'To ensure e-mail delivery, use a web-based address like Gmail. Check your spam folder.'
    super
  end

  # POST /users/registrations
  def create
    #create a customer if successful sign up
    super do |resource|
      begin
        customer = Stripe::Customer.create(
          email: sign_up_params[:email],
          description: ENV["STRIPE_CUSTOMER_DESCRIPTION"]
        )

        subscription = customer.subscriptions.create(plan: params[:plan], quantity: 1)
        save_customer_id(resource, customer.id)

        #TODO: These should probably be ActiveRecord callbacks.
        assign_admin_role(resource)
        save_active_until(resource, subscription.current_period_end)
      rescue Stripe::StripeError => e
        flash[:error] = e.message
        Rails.logger.error "Registration unsuccessful: #{e.message}"
        redirect_to new_user_registration_path and return
      rescue StandardError => e
        flash[:error] = "There was a problem! Please try again.\nIf the problem persists please contact us at #{ENV["CONTACT_EMAIL_ADDRESS"]}."
        Rails.logger.error "Registration unsuccessful: #{e.message}"
        redirect_to new_user_registration_path and return
      end
    end
  end

  private
    def save_customer_id(user, customer_id)
      user.customer_id = customer_id
      user.save!
    end

    def assign_admin_role(user)
      user.role = 'admin'
      user.save!
    end

    def save_active_until(user, timestamp)
      user.active_until = Time.zone.at(timestamp)
      user.save!
    end

    def after_sign_up_path_for(resource)
      summary_path
    end

    def after_inactive_sign_up_path_for(resource)
      new_user_session_path
    end
end