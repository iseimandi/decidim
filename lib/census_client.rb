require 'savon'

class CensusClient

  class InvalidParameter < StandardError; end

  def self.person_exists?(dni, birthdate, postal_code)
    response = client.call(
      :validarpadro_decidim,
      message: build_message(dni, birthdate, postal_code)
    )
    response_code = response.body[:validarpadro_decidim_response][:result]

    return (response_code == '0')
  end

  def self.client
    Savon.client(wsdl: census_endpoint)
  end
  private_class_method :client

  def self.build_message(dni, birthdate, postal_code)
    validate_parameters!(dni, birthdate, postal_code)

    {
      idioma: 'ca/es',
      dni: dni[0..7],
      letra: '', # letter is not checked by census
      obs: '',
      obj: '',
      datanaixement: birthdate.strftime('%d/%m/%Y'),
      cp: postal_code
    }
  end
  private_class_method :build_message

  def self.census_endpoint
    ENV['CENSUS_ENDPOINT']
  end
  private_class_method :census_endpoint

  def self.validate_parameters!(dni, birthdate, postal_code)
    if (dni.length != 9) ||
       (postal_code.nil?)
    then raise InvalidParameter end
  end
  private_class_method :validate_parameters!

end