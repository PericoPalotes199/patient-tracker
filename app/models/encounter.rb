class Encounter < ActiveRecord::Base

  belongs_to :user

  validates :encounter_type, presence: true
  validates :encountered_on, presence: true

  after_commit :transaction_success
  after_rollback :transaction_failure

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
