if Rails.env.production?
  Rails.application.configure do
    config.lograge.enabled = true

    # Also include parameters in line logged, apart from those already included
    # by default (see https://github.com/roidrage/lograge#what-it-doesnt-do).
    param_exceptions = %w[controller action format]
    config.lograge.custom_options = lambda do |event|
      {
        params: event.payload[:params].except(*param_exceptions)
      }
    end

    config.lograge.custom_payload do |controller|
      LogrageUtils.custom_payload_for(controller.request)
    end
  end

  # Patch so 404s are also shown concisely on a single line - from
  # https://github.com/roidrage/lograge/issues/146#issuecomment-461632965.
  module ActionDispatch
    class DebugExceptions
      alias old_log_error log_error

      def log_error(request, wrapper)
        exception = wrapper.exception
        if exception.is_a?(ActionController::RoutingError)
          # TODO Would be nice if this could be done in such a way that we
          # don't need to re-add all this data in a similar way to what Lograge
          # does itself, while also retaining the benefit of this approach that
          # 404s are still always handled as they would be normally (with a
          # 'Routes' page in development etc.).
          data = {
            method: request.env["REQUEST_METHOD"],
            path: request.env["REQUEST_PATH"],
            status: wrapper.status_code,
            error: "#{exception.class.name}: #{exception.message}"
          }.merge(
            LogrageUtils.custom_payload_for(request)
          )
          formatted_message = Lograge.formatter.call(data)
          logger(request).send(Lograge.log_level, formatted_message)
        else
          old_log_error request, wrapper
        end
      end
    end
  end
end
