# frozen_string_literal: true

class CensusResponse

  attr_accessor(
    :response_code,
    :registered_in_census,
    :message
  )

  def initialize(params = {})
    self.response_code = params[:code]
    self.registered_in_census = params[:success]
    self.message = params[:message]
  end

  def registered_in_census?
    registered_in_census || (response_code && response_code == "0")
  end

  def message
    @message || default_message_for(response_code)
  end

  private

  def default_message_for(code)
    case code
    when "0"
      "OK. Persona empadronada"
    when "4"
      "No està empadronat a la data de tall"
    when "5"
      "No està empadronat"
    when "6"
      "DNI repetit"
    when "7"
      "Defunció"
    when "310"
      "Menor"
    when "315"
      "Codi postal no trobat"
    when "320"
      "Data de naixement no trobada"
    when "505"
      "Paralitzat"
    when "515"
      "Sense permís de residència"
    else
      "Desconegut"
    end
  end

end
