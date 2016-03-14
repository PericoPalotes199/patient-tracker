class Encounter < ActiveRecord::Base

  scope :adult_medicine, ->{ where encounter_type: 'adult_medicine' }
  scope :icu, ->{ where encounter_type: 'icu' }
  scope :encountered_today, ->{ where 'created_at > ?', Time.zone.today }

  belongs_to :user

  validates :encounter_type, presence: true
  validates :encountered_on, presence: true

  after_commit :transaction_success
  after_rollback :transaction_failure

  private
    #TODO: improve transaction error logging!
    def transaction_success
      logger.debug "Transaction success for Encounter #{self.inspect}" unless Rails.env.test?
    end

    def transaction_failure
      logger.debug "Transaction failure for Encounter #{self.inspect}" unless Rails.env.test?
    end
end
