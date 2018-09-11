# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

require "#{Gem.loaded_specs['decidim-proposals'].full_gem_path}/lib/decidim/proposals/test/factories"

describe "Admin manages proposals", type: :system do

  # base
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:user_group) { create(:user_group, decidim_organization_id: organization.id, users: [user]) }

  # participation
  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
  end
  let(:component) do
    create(:component,
           manifest: Decidim.find_component_manifest("proposals"),
           participatory_space: participatory_process)
  end
  let!(:proposal) { create :proposal, component: component }

  def telephone_number
    "123456789"
  end

  def official_name
    "Official Name Custom"
  end

  context "when previewing proposals" do

    it "shows author contact info" do
      # BUG: I can't get the explicit user to be set as the only proposal
      # author, and the proposal factory creates an additional user wich has not the custom fields set.
      ::Decidim::User.update_all(official_name_custom: official_name, telephone_number_custom: telephone_number)
      Decidim::Coauthorship.create(author: user, user_group: user_group, coauthorable: proposal)

      switch_to_host(organization.host)

      login_as admin, scope: :user

      visit manage_component_path(component)

      assert page.has_content? "CONTACTE"
      assert page.has_content? official_name
      assert page.has_content? telephone_number
    end
  end

end
