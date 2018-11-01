class Encounter < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :encounter_type, :encountered_on, :user

  after_commit :transaction_success
  after_rollback :transaction_failure

  def self.default_encounter_types
    [
      'adult_inpatient',
      'adult_ed',
      'adult_icu',
      'adult_inpatient_surgery',
      'pediatric_inpatient',
      'pediatric_newborn',
      'pediatric_ed',
      'continuity_inpatient',
      'continuity_external'
    ]
  end

  private
    def transaction_success
      STDOUT.puts "Transaction success for Encounter #{self.inspect}" if Rails.env.development?
    end

    def transaction_failure
      warning = "Transaction failure for Encounter #{self.inspect}"
      STDOUT.puts warning if Rails.env.development?
      Rollbar.warning warning, self.attributes
    end
end
