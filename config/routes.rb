require "sidekiq/web"

Rails.application.routes.draw do

  if Rails.env.development? || Rails.env.staging?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Decidim::Core::Engine => "/"
  mount Sidekiq::Web => "/sidekiq"
end
