# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

def fill_registration_form
  fill_in :user_name, with: "Nikola Tesla"
  fill_in :user_nickname, with: "the-greatest-genius-in-history"
  fill_in :user_email, with: "nikola.tesla@example.org"
  fill_in :user_password, with: "sekritpass123"
  fill_in :user_password_confirmation, with: "sekritpass123"
end

describe "Registration", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when signing up" do
    describe "on first sight" do
      it "shows fields empty" do
        expect(page).to have_content("Crea un compte per poder participar")
        expect(page).to have_field("user_name", with: "")
        expect(page).to have_field("user_nickname", with: "")
        expect(page).to have_field("user_email", with: "")
        expect(page).to have_field("user_password", with: "")
        expect(page).to have_field("user_password_confirmation", with: "")
        expect(page).to have_field("user_newsletter", checked: false)
      end
    end
  end

end
