# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = "My Application Name"
  config.mailer_sender = Rails.application.secrets.mailer_sender
  config.default_locale = :ca
  config.available_locales = [:ca, :es]

  # Geocoder configuration

  config.geocoder = {
    static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview",
    here_app_id: Rails.application.secrets.geocoder[:here_app_id],
    here_app_code: Rails.application.secrets.geocoder[:here_app_code]
  }

  # Custom resource reference generator method
  # config.resource_reference_generator = lambda do |resource, feature|
  #   # Implement your custom method to generate resources references
  #   "1234-#{resource.id}"
  # end

  # Currency unit
  # config.currency_unit = "€"

  # The number of reports which an object can receive before hiding it
  # config.max_reports_before_hiding = 3

  # Custom HTML Header snippets
  #
  # The most common use is to integrate third-party services that require some
  # extra JavaScript or CSS. Also, you can use it to add extra meta tags to the
  # HTML. Note that this will only be rendered in public pages, not in the admin
  # section.
  #
  # Before enabling this you should ensure that any tracking that might be done
  # is in accordance with the rules and regulations that apply to your
  # environment and usage scenarios. This feature also comes with the risk
  # that an organization's administrator injects malicious scripts to spy on or
  # take over user accounts.
  #
  config.enable_html_header_snippets = false
end

Decidim::Verifications.register_workflow(:census_authorization_handler) do |auth|
  auth.form = "CensusAuthorizationHandler"
end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale

# Override this Decidim method, since the fix has not been released yet
#
# our rollbar: https://rollbar.com/Populate/decidim-reus/items/29/
# decidim rollbar: https://sentry.io/share/issue/6186537079b14d678c4aa63e78fc0af0/
# PR fix: https://github.com/decidim/decidim/pull/2753/commits/de77190a5a784e41d9a5255fe2b763c6b8da51b6#diff-c5c9cf407e51f6c859a6d77754595162

# module Decidim
#   module Verifications
#     class DefaultActionAuthorizer
#       #
#       # Initializes the DefaultActionAuthorizer class.
#       #
#       # authorization - The existing authorization record to be evaluated. Can be nil.
#       # options       - A hash with options related only to the current authorization process.
#       #
#       def initialize(authorization, options)
#         @authorization = authorization
#         @options = options.deep_dup || {} # options hash is cloned to allow changes applied to it without risks
#       end

#     end
#   end
# end
