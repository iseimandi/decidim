# frozen_string_literal: true

require "spec_helper"
require "rails_helper"
require "census_client"

describe "Verification", type: :system do
  let(:organization) { build :organization, available_authorizations: ["census_authorization_handler"] }
  let(:user) { create(:user, :confirmed, password: password, password_confirmation: password, organization: organization) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:official_name) { "Napoleón Bonaparte" }
  let(:telephone_number) { "123456789" }

  def fill_in_authorization_form(options = {})
    fill_in "authorization_handler[document_number]", with: "12345678"
    select "12", from: "authorization_handler_date_of_birth_3i"
    select "January", from: "authorization_handler_date_of_birth_2i"
    select "1979", from: "authorization_handler_date_of_birth_1i"
    fill_in "authorization_handler[postal_code]", with: "12345"

    if options[:with_custom_fields]
      fill_in "authorization_handler[official_name_custom]", with: official_name
      fill_in "authorization_handler[telephone_number_custom]", with: "123 456.789"
    end
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.account_path
    click_link "Authorizations"
  end

  context "when user is registered in census" do

    before do
      allow(CensusClient).to receive(:person_exists?).and_return(true)
    end

    describe "when official name and telephone number are missing" do
      it "sets them and creates the authorization" do
        click_link "Padró municipal"

        fill_in_authorization_form(with_custom_fields: true)

        click_button "Autoritzar"

        expect(page).to have_content("You've been successfully authorized")

        user.reload

        expect(user.official_name_custom).to eq(official_name)
        expect(user.telephone_number_custom).to eq(telephone_number)
        expect(::Decidim::Authorization.exists?(decidim_user_id: user.id)).to be_truthy
      end
    end

    describe "when official name and telephone number are already set" do
      before do
        user.update_attributes!(official_name_custom: official_name, telephone_number_custom: telephone_number)
      end

      it "creates the authorization" do
        click_link "Padró municipal"

        refute has_field? "authorization_handler[official_name_custom]"
        refute has_field? "authorization_handler[telephone_number_custom]"

        fill_in_authorization_form

        click_button "Autoritzar"

        expect(page).to have_content("You've been successfully authorized")

        user.reload

        expect(user.official_name_custom).to eq(official_name)
        expect(user.telephone_number_custom).to eq(telephone_number)
        expect(::Decidim::Authorization.exists?(decidim_user_id: user.id)).to be_truthy
      end
    end

  end

  context "when user is not registered in census" do

    before do
      allow(CensusClient).to receive(:person_exists?).and_return(false)
    end

    it "rejects the authorization and does not update custom fields" do
      click_link "Padró municipal"

      fill_in_authorization_form(with_custom_fields: true)

      click_button "Autoritzar"

      expect(page).to have_content("There was an error creating the authorization")

      user.reload

      expect(user.official_name_custom).to be_nil
      expect(user.telephone_number_custom).to be_nil
      expect(::Decidim::Authorization.exists?(decidim_user_id: user.id)).to be_falsey
    end

  end

end
