require "savon"
require "census_response"

class CensusClient

  class InvalidParameter < StandardError; end

  def self.make_request(original_document_number, original_formatted_birthdate, original_postal_code)
    document_number = original_document_number.dup.to_s
    formatted_birthdate = original_formatted_birthdate.dup.to_s
    postal_code = original_postal_code.dup

    message = build_message(document_number, formatted_birthdate, postal_code)

    Rails.logger.info "[Census WS] Sending request with message: #{obfuscated_message(message)}"

    if (Rails.env.staging? || Rails.env.development?) && original_document_number.include?("#")
      # Try 12345678#315
      response_code = original_document_number.split("#").last
    else
      response = client.call(:validarpadro_decidim, message: message)
      response_code = response.body[:validarpadro_decidim_response][:result]
    end

    Rails.logger.info "[Census WS] Response code was: #{response_code}"

    return CensusResponse.new(code: response_code)
  rescue InvalidParameter
    CensusResponse.new(code: nil, success: false, message: "Paràmetre invàlid")
  end

  def self.client
    Savon.client(wsdl: census_endpoint)
  end
  private_class_method :client

  def self.build_message(document_number, formatted_birthdate, postal_code)
    # if document matches DNI pattern or NIE, remove last letter
    if (/^\d{8}[a-zA-Z]$/.match(document_number)) || (/^[a-zA-Z]\d{7}[a-zA-Z]$/.match(document_number))
      document_number.chop!
    end

    validate_parameters!(document_number, formatted_birthdate, postal_code)

    {
      idioma: 'ca/es',
      dni: document_number,
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

  def self.validate_parameters!(document_number, formatted_birthdate, postal_code)
    if /^\d{5}$/.match(postal_code).nil? || /^\d{2}\/\d{2}\/\d{4}$/.match(formatted_birthdate).nil?
      Rails.logger.info "[Census WS] Attempted to build invalid message: document_number=#{obfuscated_document_number(document_number)}, formatted_birthdate=#{obfuscated_formatted_birthdate(formatted_birthdate)}, postal_code=#{obfuscated_postal_code(postal_code)}"
      raise InvalidParameter
    end
  end
  private_class_method :validate_parameters!

  def self.obfuscated_message(message)
    message.merge(
      dni: obfuscated_document_number(message[:dni]),
      cp: obfuscated_postal_code(message[:cp]),
      datanaixement: obfuscated_formatted_birthdate(message[:datanaixement])
    )
  end

  def self.obfuscated_document_number(document_number)
    return "<invalid length>" if document_number.length < 6
    obfuscated_document_number = document_number.dup
    obfuscated_document_number[2..5] = "****"
    obfuscated_document_number
  end

  def self.obfuscated_formatted_birthdate(formatted_birthdate)
    return "<invalid length>" if formatted_birthdate.length < 2
    obfuscated_formatted_birthdate = formatted_birthdate.dup
    obfuscated_formatted_birthdate[0..1] = "**"
    obfuscated_formatted_birthdate
  end

  def self.obfuscated_postal_code(postal_code)
    return "<invalid length>" if postal_code.length < 5
    obfuscated_postal_code = postal_code.dup
    obfuscated_postal_code[3..4] = "**"
    obfuscated_postal_code
  end

end
