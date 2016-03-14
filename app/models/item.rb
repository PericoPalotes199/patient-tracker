class Item < ActiveRecord::Base
  belongs_to :organization

  before_save :set_name

  # Name method is used because $ rake test test/models/user_test.rb
  # does not trigger set_name callback.
  private
    def set_name
      self.name = self.label.parameterize('_')
    end
end
