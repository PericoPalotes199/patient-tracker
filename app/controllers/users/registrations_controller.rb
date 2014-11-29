class Users::RegistrationsController < Devise::RegistrationsController
  # GET /users/sign_up
  def new
    super
  end

  # POST /users/registrations
  def create
    #process credit card if successful sign up
    super do |resource|
      begin
        #Amount in cents
        @amount = 100_00
        customer = Stripe::Customer.create(
          email: sign_up_params[:email],
          card: params[:stripeToken]
        )

        charge = Stripe::Charge.create(
          customer: customer.id,
          amount: @amount,
          description: 'Rails Development Customer',
          currency: 'usd'
        )

      rescue Stripe::CardError => e
        flash[:error] = e.message
        redirect_to new_user_registration_path
      rescue Stripe::StripeError => e
        flash[:error] = "Payment unsuccessful."
        #TODO: send an e-mail to application owner
        redirect_to new_user_registration_path
      end
    end
  end
end
