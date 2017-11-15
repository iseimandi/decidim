# frozen_string_literal: true

require 'census_client'

class CensusAuthorizationHandler < Decidim::AuthorizationHandler

  attribute :document_number, String
  attribute :postal_code, String
  attribute :date_of_birth, Date

  validates :date_of_birth, presence: true
  validates :document_number, presence: true, format: { with: /\A[0-9]*\z/ }, length: { is: 8 }
  validates :postal_code, presence: true, format: { with: /\A[0-9]*\z/ }, length: { is: 5 }

  validate :user_exists_in_census

  def self.from_params(params, additional_params = {})
    instance = super(params, additional_params)

    params_hash = hash_from(params)

    if params_hash["date_of_birth(1i)"]
      date = Date.civil(
        params["date_of_birth(1i)"].to_i,
        params["date_of_birth(2i)"].to_i,
        params["date_of_birth(3i)"].to_i
      )

      instance.date_of_birth = date
    end

    instance
  end

  def unique_id
    Digest::MD5.hexdigest(
      "#{document_number}-#{formatted_birthdate}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def user_exists_in_census
    if !CensusClient.person_exists?(document_number, formatted_birthdate, postal_code)
      errors.add(:wadus, 'wadus')
    end
  end

  def formatted_birthdate
    date_of_birth.strftime('%d/%m/%Y') if date_of_birth.present?
  end

end
