class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :encounters, dependent: :destroy

  before_save :set_default_name, :set_default_role

  def admin?
    role == 'admin'
  end

  def resident?
    role == 'resident'
  end

  private
    def set_default_name
      self.name = first_name + ' ' + last_name
    end

    def set_default_role
      self.role ||= 'resident'
    end
end
