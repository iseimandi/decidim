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

    let(:dni_number) { '12345678' }
    let(:birthdate) { Date.civil(1994, 12, 30).strftime('%d/%m/%Y') }
    let(:postal_code) { '12345' }

    it 'is true when person exists' do
      stubbed_response_body = { validarpadro_decidim_response: { result: '0' } }
      stub_census_client(stubbed_response_body)

      result = CensusClient.person_exists?(dni_number, birthdate, postal_code)

      expect(result).to be_truthy
    end

    it 'is false when person does not exist' do
      stubbed_response_body = { validarpadro_decidim_response: { result: 'wadus' } }
      stub_census_client(stubbed_response_body)

      result = CensusClient.person_exists?(dni_number, birthdate, postal_code)

      expect(result).to be_falsey
    end

    context 'raises exceptions' do
      before do
        stubbed_response_body = { validarpadro_decidim_response: { result: 'wadus' } }
        stub_census_client(stubbed_response_body)
      end

      it 'for invalid dni_number' do
        dni_number = '123456789'

        expect do
          CensusClient.person_exists?(dni_number, birthdate, postal_code)
        end.to raise_error(CensusClient::InvalidParameter)
      end

      it 'for invalid postal_code' do
        postal_code = '123456'

        expect do
          CensusClient.person_exists?(dni_number, birthdate, postal_code)
        end.to raise_error(CensusClient::InvalidParameter)
      end

      it 'for invalid birthdate' do
        birthdate = nil

        expect do
          CensusClient.person_exists?(dni_number, birthdate, postal_code)
        end.to raise_error(CensusClient::InvalidParameter)
      end
    end

  end

end
