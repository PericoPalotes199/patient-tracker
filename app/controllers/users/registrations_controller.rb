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
        #Amount in cents
        @amount = 100_00
        customer = Stripe::Customer.create(
          email: sign_up_params[:email],
          description: ENV["STRIPE_CUSTOMER_DESCRIPTION"],
          card: params[:stripeToken]
        )

        #Charge the Customer, not the card
        charge = Stripe::Charge.create(
          amount: @amount,
          description: 'Rails Development Customer',
          currency: 'usd',
          customer: customer.id
        )

        save_customer_id(resource, customer.id)
        assign_admin_role(resource)

      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_user_registration_path
      rescue Stripe::StripeError => e
        flash[:error] = "Payment unsuccessful."
        #TODO: send an e-mail to application owner
        redirect_to new_user_registration_path
      rescue => e
        flash[:error] = "unsuccessful. Please contact #{ENV[""]}"
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
end
