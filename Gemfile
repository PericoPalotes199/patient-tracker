source 'https://rubygems.org'
ruby '2.4.5'

gem 'rails', '4.2.10'

gem 'devise', '~> 3.4.1'
gem 'devise_invitable', '~> 1.4.0'
# Simple, Heroku-friendly Rails app configuration using ENV and a single YAML file
gem 'figaro', '~> 1.1.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 3.1.4'
# Use PostgreSQL database in all environments
gem 'pg', '~> 0.17.1'
# Use pundit for minimal authorization through OO design and pure Ruby classes
gem 'puma', '~> 2.11.2'
gem 'pundit', '~> 0.2.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Stripe for payments
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'
gem 'stripe_event', '~> 1.4.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.2.2'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use unicorn as the app server
# gem 'unicorn'

# Analytics
gem 'newrelic_rpm', '~> 3.18.1.330'
gem 'rollbar', '2.15.5'
gem 'scout_apm'

group :development do
  # Spring speeds up development by keeping your application running in the background.
  # Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.0.2'
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem 'awesome_print'
  gem 'better_errors', '~> 1.1.0'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'pry'
  gem 'pry-byebug'
  gem 'webmock'
end

group :test do
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'minitest-spec-rails', '~> 5.4.0'
  gem 'simplecov', '~> 0.16.1', require: false
end

group :production do
  gem 'rails_12factor', '~> 0.0.3'
end
