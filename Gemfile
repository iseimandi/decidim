# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

decidim_path = if ENV["RAILS_ENV"] == "development"
                 { path: "#{ENV['DEV_DIR']}/decidim-populate" }
               else
                 { git: "https://github.com/populatetools/decidim", branch: "reus-custom-0.19.0" }
               end

gem "decidim", decidim_path

gem "bootsnap", require: false
gem "puma", "~> 3.12"
gem "uglifier", ">= 1.3.0"
gem "faker", "~> 1.8.4"
gem "rollbar"
gem "savon"
gem "progressbar"
gem "deface"
gem "letter_opener_web", "~> 1.3.0"
gem "sidekiq", "~> 5.2.1"

group :development, :test do
  gem "byebug", platform: :mri
  gem "rspec"
  gem "decidim-dev", decidim_path
end

group :development do
  gem "listen", "~> 3.1.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end
