# Require configuration keys for env vars
if Rails.env != 'test'
  Figaro.require_keys(
    'DEFAULT_URL_OPTIONS_HOST',
    'DEVISE_MAILER_SENDER',
    'FROM_ADDRESS',
    'GMAIL_REPLY_TO',
    'GMAIL_BCC',
    'SMTP_ADDRESS',
    'SMTP_DOMAIN',
    'SMTP_USERNAME',
    'SMTP_PASSWORD',
    'STRIPE_TEST_PUBLISHABLE_KEY',
    'STRIPE_TEST_SECRET_KEY',
    'STRIPE_LIVE_PUBLISHABLE_KEY',
    'STRIPE_LIVE_SECRET_KEY',
    'CONTACT_EMAIL_ADDRESS'
  )
end
