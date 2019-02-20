# frozen_string_literal: true

require "sidekiq/web"

Sidekiq::Logging.logger.level = Rails.logger.level

redis_database = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" } }

Sidekiq.configure_server do |config|
  config.redis = redis_database
end

Sidekiq.configure_client do |config|
  config.redis = redis_database
end
