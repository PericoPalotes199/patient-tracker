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
      subscription.quantity = @user.invitations.count
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
    Rails.logger.info "*** Payment unsuccessful: problem with payment page. ***"
    redirect_to payment_info_path
  end

  # POST /users/registrations
  def create
    # If the user (a new admin) did not provide a residency upon login - redirect.
    begin
      residency = Residency.create! name: params[:user][:residency_name]
    rescue StandardError => e
      flash[:error] = 'You must provide a residency.'
      Rails.logger.error "Registration unsuccessful: #{e.message}"
      Rollbar.warning "#{e.class} caught. Registration unsuccessful: #{e.message}"
      # NOTE: Unfortuntely, this renders a new page and the user must re-type all form values
      redirect_to new_user_registration_path and return
    end

    super do |user|
      begin
        # When a user signs up, they should be assigned the admin role
        # Otherwise, they are a resident, and should be invited instead (or manually change the role)

        # If we can successfully update the user's role (indicating the user is still valid),
        # then proceed with creatinga a customer and subscription.
        if user.update! role: 'admin', residency: residency
          customer = Stripe::Customer.create(
            email: sign_up_params[:email],
            description: "#{ENV['STRIPE_CUSTOMER_DESCRIPTION']} #{params[:user][:residency_name]}"
          )
          subscription = customer.subscriptions.create(plan: params[:plan], quantity: 1)

          user.update!(
            customer_id: customer.id,
            active_until: Time.zone.at(subscription.current_period_end)
          )
        end
      rescue Stripe::StripeError => e
        flash[:error] = e.message
        Rails.logger.error "Registration unsuccessful: #{e.message}"
        Rollbar.warning "Stripe::StripeError caught. Registration unsuccessful: #{e.message}"
        redirect_to new_user_registration_path and return
      rescue StandardError => e
        Rails.logger.warn "Registration unsuccessful: #{e.message}"
        Rollbar.warning "StandardError caught. Registration unsuccessful: #{e.message}"
        # NOTE: Do not return - let the user finish being processed by the Devise::RegistrationsController
      end
    end
  end

  private
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
