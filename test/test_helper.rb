ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
# Use the Rails profile to start SimpleCov
# Reference: https://github.com/colszowka/simplecov/tree/v0.16.1#profiles
SimpleCov.start 'rails'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module EncountersFixturesHelpers
  def default_encounters_types
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
end
# This includes a helper module for fixtures:
# http://api.rubyonrails.org/v4.2.10/classes/ActiveRecord/FixtureSet.html#class-ActiveRecord::FixtureSet-label-Dynamic+fixtures+with+ERB
ActiveRecord::FixtureSet.context_class.send :include, EncountersFixturesHelpers

class ActionController::TestCase
  include Devise::TestHelpers
end

# As suggested by the guides
# Reference: http://guides.rubyonrails.org/testing.html#test-helpers

module SignInHelper
  def sign_in_as(sign_in_params)
    post new_user_session_url({ user: sign_in_params.slice(:email, :password) })
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
