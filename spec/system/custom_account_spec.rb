# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

describe "Account", type: :system do
  let(:user) { create(:user, :confirmed, password: password, password_confirmation: password) }
  let(:password) { "dqCFgjfDbC7dPbrv" }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when on the account page" do
    before do
      puts "Visit: #{decidim.account_path}"
      visit decidim.account_path
    end

    describe "updating personal data" do
      it "updates the user's data" do
        within "form.edit_user" do
          fill_in :user_name, with: "Normal User Name"
          fill_in :user_official_name_custom, with: "Official User Name"
          fill_in :user_personal_url, with: "https://example.org"
          fill_in :user_about, with: "User Biography Text"
          fill_in :user_telephone_number_custom, with: "123456789"
          find("*[type=submit]").click
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        within ".title-bar" do
          expect(page).to have_content("Normal User Name")
        end

        user.reload

        within_user_menu do
          find("a", text: "public profile").click
        end

        visit decidim.account_path

        expect(page).to have_selector("input[value='Normal User Name']")
        expect(page).to have_selector("input[value='Official User Name']")
        assert page.has_content?("User Biography Text")
        expect(page).to have_selector("input[value='123456789']")
      end
    end

  end
end
