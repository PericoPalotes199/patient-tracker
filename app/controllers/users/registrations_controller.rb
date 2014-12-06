class Users::RegistrationsController < Devise::RegistrationsController
  # GET /users/sign_up
  def new
    super
  end

  # POST /users/registrations
  def create
    #process credit card if successful sign up
    params[:user][:email] = params[:stripeEmail]
    super do |resource|
      begin
        @amount = 100 #Amount in cents
        customer = Stripe::Customer.create(
          email: sign_up_params[:email],
          description: ENV["STRIPE_CUSTOMER_DESCRIPTION"],
          card: params[:stripeToken]
        )
        subscription = customer.subscriptions.create(plan: 'monthly', quantity: 1)
        save_customer_id(resource, customer.id)

        #TODO: These should probably be ActiveRecord callbacks.
        assign_admin_role(resource)
        save_active_until(resource, subscription.current_period_end)

      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_user_registration_path
      rescue Stripe::StripeError => e
        flash[:error] = "Payment unsuccessful."
        #TODO: send an e-mail to application owner
        redirect_to new_user_registration_path
      rescue => e
        flash[:error] = "Unsuccessful. Please contact #{ENV["CONTACT_EMAIL_ADDRESS"]}"
        redirect_to new_user_registration_path
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
end
