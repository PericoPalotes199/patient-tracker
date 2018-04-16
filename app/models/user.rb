class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable

  has_many :encounters
  has_many :invitations, :class_name => 'User', :as => :invited_by
  after_invitation_accepted :update_inviter_subscription_quantity,
                            :delete_all_customer_subscriptions,
                            :change_role_to_resident,
                            :set_active_until,
                            :set_residency

  before_create :set_default_role, :set_active_until
  before_save :set_name

  validates_presence_of   :email
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
  validates_format_of     :email, with: /\A[^@]+@[^@]+\z/, allow_blank: true, if: :email_changed?
  # Validating the residency prevents a bunch of admins and residents from being
  # grouped into the same nil residency
  validates_presence_of   :residency, message: 'is required.', if: :admin?

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: 8..128, allow_blank: true

  validates_acceptance_of :tos_accepted, accept: true, allow_nil: false

  def admin?
    role == 'admin'
  end

  def resident?
    role == 'resident'
  end

  def admin_resident?
    role == 'admin_resident'
  end

  # TODO: This method always returns false, but we are anticipating
  # a boolean attribute to be added to the model.
  def has_custom_labels?
    false
  end

  def subscription_expired?
    return true unless active_until
    Time.zone.at(active_until) < Time.zone.now
  end

  def days_until_subscription_expiration
    ((Time.zone.at(active_until) - Time.zone.now) / (3600 * 24)).floor
  end

  def update_invitees_active_until
    invitations.update_all(active_until: active_until)
  end

  private
    def set_name
      if first_name.present? && last_name.present? # false if first_name == ''
        self.name = "#{first_name} #{last_name}"
      else
        self.name = email
      end
    end

    def set_default_role
      self.role ||= 'resident'
    end

    def change_role_to_resident
      self.role = 'resident'
    end

    def set_active_until
      if invited_by_id?
        self.active_until = invited_by.active_until
      end
    end

    def set_residency
      if invited_by_id?
        self.residency = invited_by.residency
      end
    end

    def update_inviter_subscription_quantity
      inviter = self.invited_by
      if inviter && inviter.customer_id
        customer = Stripe::Customer.retrieve(inviter.customer_id)
        subscription = customer.subscriptions.first
        subscription.quantity = inviter.invitations.count
        subscription.save
      end
    end

    def delete_all_customer_subscriptions
      if customer_id
        begin
          customer = Stripe::Customer.retrieve(customer_id)
          subscriptions = customer.subscriptions
          subscriptions.each do |subscription|
            subscription.delete
          end
        rescue Stripe::StripeError => e
          Rails.logger.error "********** Stripe Error: #{e.message} **********"
          Rollbar.error e.class, e.message
          return false
        end
      end
      return true
    end

  protected
    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end
end
