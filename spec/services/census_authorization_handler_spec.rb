# coding: utf-8

require "rails_helper"
require "decidim/dev/test/authorization_shared_examples"

describe CensusAuthorizationHandler do
  let(:subject) { handler }
  let(:handler) { described_class.from_params(params) }
  let(:document_number) { "12345678" }
  let(:date_of_birth) { Date.civil(1987, 9, 17) }
  let(:postal_code) { '12345' }
  let(:user) { create(:user, organization: organization) }
  let(:other_user) { create(:user, organization: organization) }
  let(:organization) { create :organization }
  let(:params) do
    {
      user: user,
      document_number: document_number,
      date_of_birth: date_of_birth,
      postal_code: postal_code
    }
  end
  let(:official_name) { "Napoleón Bonaparte" }
  let(:telephone_number) { "123456789" }

  it_behaves_like "an authorization handler"

  before do
    user.update_attributes!(official_name_custom: official_name, telephone_number_custom: telephone_number)
    allow_any_instance_of(Savon::Client).to receive(:call).and_return(
      OpenStruct.new(body: { validarpadro_decidim_response: { result: "0" } })
    )
  end

  describe "document_number" do
    context "when it isn't present" do
      let(:document_number) { nil }

      it { is_expected.not_to be_valid }
    end
  end

  describe "date_of_birth" do
    context "when it isn't present" do
      let(:date_of_birth) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when data from a date field is provided" do
      let(:params) do
        {
          "date_of_birth(1i)" => "2010",
          "date_of_birth(2i)" => "8",
          "date_of_birth(3i)" => "16"
        }
      end

      let(:date_of_birth) { nil }

      it "correctly parses the date" do
        expect(subject.date_of_birth.year).to eq(2010)
        expect(subject.date_of_birth.month).to eq(8)
        expect(subject.date_of_birth.day).to eq(16)
      end
    end
  end

  describe "when everything is fine" do
    it { is_expected.to be_valid }
  end

  describe "unique_id" do
    it "is correctly constructed" do
      expected_unique_id = Digest::MD5.hexdigest("12345678-17/09/1987-#{Rails.application.secrets.secret_key_base}")
      expect(subject.unique_id).to eq(expected_unique_id)
    end

    it "avoids duplicates" do
      handler_params = {
        document_number: "12345678A",
        date_of_birth: date_of_birth,
        postal_code: postal_code
      }

      first_handler = described_class.from_params(
        handler_params.merge(user: user)
      )

      expect(first_handler).to be_valid

      expect(Decidim::Authorization.count).to eq 0

      Decidim::Authorization.create_or_update_from(first_handler)

      expect(Decidim::Authorization.count).to eq 1

      second_handler = described_class.from_params(
        handler_params.merge(user: other_user)
      )

      expect(second_handler).to_not be_valid

      Decidim::Verifications::AuthorizeUser.call(second_handler) do
        on(:ok) do
          Decidim::Authorization.create_or_update_from(second_handler)
        end
        on(:invalid) {}
      end

      expect(Decidim::Authorization.count).to eq 1
    end
  end

end
