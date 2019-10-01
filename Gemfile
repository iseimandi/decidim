# frozen_string_literal: true

source "https://rubygems.org"

DECIDIM_VERSION = "0.18.0"

ruby RUBY_VERSION

if ENV["RAILS_ENV"] == "development"
  decidim_path = { path: "#{ENV['DEV_DIR']}/decidim-populate" }
else
  decidim_path = { git: "https://github.com/populatetools/decidim", branch: "verifications-audit" }
end

gem "decidim", decidim_path

gem "bootsnap", require: false
gem "puma", "~> 3.0"
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
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "listen", "~> 3.1.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end
