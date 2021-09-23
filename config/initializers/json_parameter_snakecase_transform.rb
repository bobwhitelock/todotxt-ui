# Transform JSON request parameter keys from JSON-conventional camelCase to
# Ruby-conventional snake_case.
# From https://stackoverflow.com/a/30557924/2620402.
ActionDispatch::Request.parameter_parsers[:json] = lambda do |raw_post|
  # Modified from `action_dispatch/http/parameters.rb`.
  data = ActiveSupport::JSON.decode(raw_post)

  if data.is_a?(Array)
    data.map { |item| item.deep_transform_keys!(&:underscore) }
  else
    data.deep_transform_keys!(&:underscore)
  end

  data.is_a?(Hash) ? data : {_json: data}
end
