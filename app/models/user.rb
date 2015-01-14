class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable

  has_many :encounters, dependent: :destroy
  has_many :invitations, :class_name => 'User', :as => :invited_by
  after_invitation_accepted :update_inviter_subscription_quantity

  before_create :set_default_role, :set_active_until
  before_save :set_name

  validates_presence_of   :email, if: :email_required?
  validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
  validates_format_of     :email, with: /\A[^@]+@[^@]+\z/, allow_blank: true, if: :email_changed?

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

  def subscription_expired?
    return !active_until unless active_until
    Time.zone.at(active_until) < Time.zone.now
  end

  def days_until_subscription_expiration
    ((Time.zone.at(active_until) - Time.zone.now) / (3600 * 24)).floor
  end

  private
    def set_name
      if first_name && last_name
        self.name = first_name + ' ' + last_name
      elsif email
        self.name = email
      else
        self.name = ''
      end
    end

    def set_default_role
      self.role ||= 'resident'
    end

    def set_active_until
      if invited_by_id?
        self.active_until = invited_by.active_until
      end
    end

    def update_invitees_active_until
      invitations.update_all(active_until: active_until)
    end

    def update_inviter_subscription_quantity
      customer = Stripe::Customer.retrieve(self.invited_by.customer_id)
      subscription = customer.subscriptions.first
      subscription.quantity += 1
      subscription.save
    end

  protected
    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

    def email_required?
      true
    end
end
