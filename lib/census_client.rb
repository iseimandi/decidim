require 'savon'

class CensusClient

  class InvalidParameter < StandardError; end

  def self.person_exists?(dni_number, formatted_birthdate, postal_code)
    message = build_message(dni_number, formatted_birthdate, postal_code)

    Rails.logger.info "[Census WS] Sending request with message: #{message}"

    response = client.call(:validarpadro_decidim, message: message)
    response_code = response.body[:validarpadro_decidim_response][:result]

    Rails.logger.info "[Census WS] Response code was: #{response_code}"

    return (response_code == '0')
  rescue InvalidParameter
    return false
  end

  def self.client
    Savon.client(wsdl: census_endpoint)
  end
  private_class_method :client

  def self.build_message(dni_number, formatted_birthdate, postal_code)
    validate_parameters!(dni_number, formatted_birthdate, postal_code)

    {
      idioma: 'ca/es',
      dni: dni_number,
      letra: '', # letter is not checked by census
      obs: '',
      obj: '',
      datanaixement: formatted_birthdate,
      cp: postal_code
    }
  end
  private_class_method :build_message

  def self.census_endpoint
    ENV['CENSUS_ENDPOINT']
  end
  private_class_method :census_endpoint

  def self.validate_parameters!(dni_number, formatted_birthdate, postal_code)
    if /^\d{8}$/.match(dni_number).nil? || /^\d{5}$/.match(postal_code).nil? || /^\d{2}\/\d{2}\/\d{4}$/.match(formatted_birthdate).nil?
      Rails.logger.info "[Census WS] Attempted to build invalid message: dni_number=#{dni_number}, formatted_birthdate=#{formatted_birthdate}, postal_code=#{postal_code}"
      raise InvalidParameter
    end
  end
  private_class_method :validate_parameters!

end