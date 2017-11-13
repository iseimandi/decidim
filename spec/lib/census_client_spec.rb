# coding: utf-8
# frozen_string_literal: true
require_relative '../rails_helper'
require 'census_client'

def stub_census_client(desired_response_body)
  response = double('soap_response')
  allow(response).to receive(:body).and_return(desired_response_body)

  client = double('soap_client')
  allow(client).to receive(:call).and_return(response)

  allow(Savon).to receive(:client).and_return(client)
end

describe CensusClient do

  describe '::person_exists?' do

    let(:dni) { '12345689A' }
    let(:birthdate) { Date.civil(1994, 12, 30) }
    let(:postal_code) { 28003 }

    it 'is true when person exists' do
      stubbed_response_body = { validarpadro_decidim_response: { result: '0' } }
      stub_census_client(stubbed_response_body)

      result = CensusClient.person_exists?(dni, birthdate, postal_code)

      expect(result).to be_truthy
    end

    it 'is false when person does not exist' do
      stubbed_response_body = { validarpadro_decidim_response: { result: 'wadus' } }
      stub_census_client(stubbed_response_body)

      result = CensusClient.person_exists?(dni, birthdate, postal_code)

      expect(result).to be_falsey
    end

    it 'raises exceptions for bad formatted data' do
      stubbed_response_body = { validarpadro_decidim_response: { result: 'wadus' } }
      stub_census_client(stubbed_response_body)

      dni = 'wadus'

      expect do
        CensusClient.person_exists?(dni, birthdate, postal_code)
      end.to raise_error(CensusClient::InvalidParameter)

      dni = '12345689'

      expect do
        CensusClient.person_exists?(dni, birthdate, postal_code)
      end.to raise_error(CensusClient::InvalidParameter)
    end

  end

end
