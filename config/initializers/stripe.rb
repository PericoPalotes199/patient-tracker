# include WebMock::API
# WebMock.allow_net_connect!

Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_LIVE_PUBLISHABLE_KEY'],
  secret_key: ENV['STRIPE_LIVE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

class StripeEventLogger
  def initialize(logger)
    @logger = logger
  end

  def call(event)
    # Event handling
    @logger.info "BILLING:#{event.type}:#{event.id}"
  end
end

StripeEvent.configure do |events|
  # # StripeEvent sends a GET request via Stripe::Event.retrieve(event.id) to verify authenticity
  # # Stub out a charge.succeeded event with webmock to be able to use 'Test Webhook' button
  # stub_request(:get, "https://api.stripe.com/v1/events/evt_00000000000000").
  #   to_return(
  #     status: 200,
  #     body: File.read( Rails.root.join("test/fixtures/stripe_events/invoice_payment_succeeded.json")
  #   )
  # )

  # # Stub out Stripe::Customer.retrieve request
  # stub_request(:get, "https://api.stripe.com/v1/customers/cus_00000000000000").
  #   to_return(
  #     status: 200,
  #     body: File.read( Rails.root.join("test/fixtures/stripe_objects/stripe_customer.json")
  #   )
  # )

  # # Stub out customer.subscriptions request
  # stub_request(:get, "https://api.stripe.com/v1/customers/cus_00000000000000/subscriptions").
  #   to_return(
  #     status: 200,
  #     body: File.read( Rails.root.join("test/fixtures/stripe_objects/customer_subscriptions.json")
  #   )
  # )

  # # Stub out customer.retrieve('sub_00000000000000') request
  # # Stub out cusomter.subscriptions.retrieve('sub_00000000000000') request
  # stub_request(:get, "https://api.stripe.com/v1/customers/cus_00000000000000/subscriptions/sub_00000000000000").
  #   to_return(
  #     status: 200,
  #     body: File.read( Rails.root.join("test/fixtures/stripe_objects/subscription.json")
  #   )
  # )



  # events.all StripeEventLogger.new(Rails.logger)
  # events.subscribe 'charge.failed' do |event|
    # Define subscriber behavior based on the event object
    # event.class       #=> Stripe::Event
    # event.type        #=> "charge.failed"
    # event.data.object #=> #<Stripe::Charge:0x3fcb34c115f8>
  # end

  events.subscribe 'customer.created' do |event|
    Rails.logger.info '**************************************************'
    Rails.logger.info event
    Rails.logger.info '**************************************************'
  end

  events.subscribe 'customer.card.created' do |event|
    Rails.logger.info '**************************************************'
    Rails.logger.info event
    Rails.logger.info '**************************************************'
  end

  events.subscribe 'customer.updated' do |event|
    Rails.logger.info '**************************************************'
    Rails.logger.info event
    Rails.logger.info '**************************************************'
  end

  events.subscribe 'invoice.created' do |event|
    Rails.logger.info '**************************************************'
    Rails.logger.info event
    Rails.logger.info '**************************************************'
  end

  events.subscribe 'invoice.payment_succeeded' do |event|
    customer_id = event.data.object.customer
    subscription_id = event.data.object.subscription


    if customer_id && subscription_id
      customer = Stripe::Customer.retrieve(customer_id)
      subscription = customer.subscriptions.retrieve(subscription_id)
      #User with customer_id: 'cus_00000000000000' saved in dev database
      user = User.find_by(customer_id: customer_id)
      user.active_until = subscription.current_period_end
      user.update_invitees_active_until
      #TODO: update the subscription quantity with only active && accepted users
      #TODO: update the quanity based on the entire residency's users,
      #TODO: so that multiple admin's can exist (like chief's are admins)
      subscription.quantity = user.invitations.count + 1
      subscription.save
      if user.save
        Rails.logger.info '**************************************************'
        Rails.logger.info "#{event.type} webhook successful."
        Rails.logger.info event
        Rails.logger.info '**************************************************'
      else
        Rails.logger.info '**************************************************'
        Rails.logger.info "#{event.type} webhook failed on user.save."
        Rails.logger.info event
        Rails.logger.info '**************************************************'
        #TODO: send an email to application owner upon failure, or maybe Stripe will?
        raise StripeEvent::UnauthorizedError
      end
    else
      Rails.logger.info '************************************************************'
      Rails.logger.info "#{event.type} webhook failed on cusomter_id && subscription."
      Rails.logger.info event
      Rails.logger.info '************************************************************'
      #TODO: send an email to application owner upon failure, or maybe Stripe will?
      raise StripeEvent::UnauthorizedError
    end
  end

  events.subscribe 'invoice.payment_failed' do |event|
    customer_id = event.data.object.customer
    subscription_id = event.data.object.subscription

    if customer_id && subscription_id
      customer = Stripe::Customer.retrieve(customer_id)
      subscription = customer.subscriptions.retrieve(subscription_id)
      user.active_until = subscription.current_period_start
      user.update_invitees_active_until

      subscription.quantity = user.invitations.count + 1
      subscription.save

      if user.save
        Rails.logger.info '**************************************************'
        Rails.logger.info "#{event.type} webhook successful."
        Rails.logger.info event
        Rails.logger.info '**************************************************'
      else
        Rails.logger.info '**************************************************'
        Rails.logger.info "#{event.type} webhook failed on user.save."
        Rails.logger.info event
        Rails.logger.info '**************************************************'
        raise StripeEvent::UnauthorizedError
      end
    else
      Rails.logger.info '************************************************************'
      Rails.logger.info "#{event.type} webhook failed on cusomter_id && subscription."
      Rails.logger.info event
      Rails.logger.info '************************************************************'
      raise StripeEvent::UnauthorizedError
    end
  end

  events.subscribe 'customer.subscription.created' do |event|
    Rails.logger.info '**************************************************'
    Rails.logger.info event
    Rails.logger.info '**************************************************'
  end

  events.subscribe 'customer.subscription.updated' do |event|
    begin
      subscription = event.data.object
      customer_id = event.data.object.customer
      #User with customer_id: 'cus_00000000000000' saved in dev database
      user = User.find_by!(customer_id: customer_id)

      # Possible values for subscription.status are:
      # trialing, active, past_due, canceled, or unpaid.
      # Source: https://stripe.com/docs/api/ruby#subscription_object
      if subscription.status == 'trialing' || subscription.status == 'active'
        user.active_until = subscription.current_period_end
      else
        user.active_until = subscription.current_period_start
      end
      user.update_invitees_active_until
      user.save!
      Rails.logger.info '**************************************************'
      Rails.logger.info "#{event.type} webhook successful."
      Rails.logger.info event
      Rails.logger.info '**************************************************'
    rescue StandardError => e
      Rails.logger.info '**************************************************'
      Rails.logger.info "#{event.type} webhook failed: #{e.message}."
      Rails.logger.info event
      Rails.logger.info '**************************************************'
      #TODO: send an email to application owner upon failure, or maybe Stripe will?
      raise StripeEvent::UnauthorizedError
    end
  end
end


