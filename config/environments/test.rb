Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files  = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: ENV['DEFAULT_URL_OPTIONS_HOST'] }
  config.action_mailer.default_options = {
    from: ENV['FROM_ADDRESS'],
    reply_to: ENV['GMAIL_REPLY_TO'],
    bcc: ENV['GMAIL_BCC']
  }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Run tests in random order
  # Reference: http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#activesupport-testcase-default-test-order-is-now-random
  config.active_support.test_order = :random # or `:sorted` if you prefer

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
