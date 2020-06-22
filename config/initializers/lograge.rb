
if Rails.env.production?
  Rails.application.configure do
    config.lograge.enabled = true

    # Also include parameters in line logged, apart from those already included
    # by default (see https://github.com/roidrage/lograge#what-it-doesnt-do).
    param_exceptions = %w(controller action format)
    config.lograge.custom_options = lambda do |event|
      {
        params: event.payload[:params].except(*param_exceptions),
      }
    end
  end
end
