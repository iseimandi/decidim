# frozen_string_literal: true

namespace :background_jobs do

  task check_pending: [:environment] do
    stats = Sidekiq::Stats.new

    if stats.enqueued > 3
      Rollbar.error("There are #{stats.enqueued} enqueued jobs. Please review if all queues from decidim are present in config/sidekiq.yml")
    end
  end

end
