class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :encounters, dependent: :destroy

  before_save :set_default_name, :set_default_role

  def admin?
    role == 'admin'
  end

  def resident?
    role == 'resident'
  end

  def subscription_expired?
    Time.zone.at(active_until) < Time.zone.now
  end

  def days_until_subscription_expiration
    ((Time.zone.at(active_until) - Time.zone.now) / (3600 * 24)).floor
  end

  private
    def set_default_name
      self.name = first_name + ' ' + last_name
    end

    def set_default_role
      self.role ||= 'resident'
    end
end
