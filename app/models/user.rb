class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :encounters, dependent: :destroy

  before_create :set_default_role, :set_active_until
  before_save :set_name

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
end
