# Require configuration keys for env vars
Figaro.require_keys(
  'DEFAULT_URL_OPTIONS_HOST',
  'DEVISE_MAILER_SENDER',
  'FROM_ADDRESS',
  'GMAIL_REPLY_TO',
  'GMAIL_BCC',
  'SMTP_ADDRESS',
  'SMTP_DOMAIN',
  'SMTP_USERNAME',
  'SMTP_PASSWORD'
)
