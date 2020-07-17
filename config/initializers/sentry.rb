
Raven.configure do |config|
  config.dsn = Figaro.env.SENTRY_DSN
end
