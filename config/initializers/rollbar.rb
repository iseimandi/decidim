Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']

  config.enabled = false if Rails.env.development? || Rails.env.test?

  config.exception_level_filters.merge!(
    "ActionController::InvalidCrossOriginRequest" => "ignore",
    "ActionController::RoutingError" => "ignore",
    "ActionController::UnknownFormat" => "ignore"
  )

  config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env
end
