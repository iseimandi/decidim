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

::Decidim::RegistrationForm.class_eval do
  attribute :official_name_custom, String
  attribute :telephone_number_custom, String

  validates :official_name_custom, presence: true, length: { minimum: 3 }
  validates(
    :telephone_number_custom,
    presence: true,
    format: { with: /\d{9,}/, message: I18n.t("custom_errors.telephone_format") }
  )
end

::Decidim::AccountForm.class_eval do
  attribute :official_name_custom, String
  attribute :telephone_number_custom, String

  validates :official_name_custom, presence: true, length: { minimum: 3 }, if: ->(form) do
    form.current_user.official_name_custom.present?
  end
  validates(
    :telephone_number_custom,
    presence: true,
    format: { with: /\d{9,}/, message: I18n.t("custom_errors.telephone_format") },
    if: ->(form) { form.current_user.telephone_number_custom.present? }
  )
end

::Decidim::CreateRegistration.class_eval do

  private

  def create_user
    @user = ::Decidim::User.create!(
      # defined by Decidim
      email: form.email,
      name: form.name,
      nickname: form.nickname,
      password: form.password,
      password_confirmation: form.password_confirmation,
      organization: form.current_organization,
      tos_agreement: form.tos_agreement,
      newsletter_notifications_at: form.newsletter_at,
      email_on_notification: true,
      accepted_tos_version: form.current_organization.tos_version,
      # custom
      official_name_custom: form.official_name_custom,
      telephone_number_custom: form.telephone_number_custom
    )
  end

end

::Decidim::UpdateAccount.class_eval do

  private

  def update_personal_data
    # defined by Decidim
    @user.name = @form.name
    @user.nickname = @form.nickname
    @user.email = @form.email
    @user.personal_url = @form.personal_url
    @user.about = @form.about
    # custom
    @user.official_name_custom = @form.official_name_custom
    @user.telephone_number_custom = @form.telephone_number_custom
  end

end
