
Raven.configure do |config|
  config.dsn = Figaro.env.SENTRY_DSN
  config.silence_ready = true
end
