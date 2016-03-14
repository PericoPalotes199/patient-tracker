class Item < ActiveRecord::Base
  belongs_to :organization

  after_create :set_name

  # Name method is used because $ rake test test/models/user_test.rb
  # does not trigger set_name callback.
  def name
    self.attributes["name"] || self.label.remove(' ').underscore
  end

  private
    def set_name
      update(name: self.label.remove(' ').underscore)
    end
end
