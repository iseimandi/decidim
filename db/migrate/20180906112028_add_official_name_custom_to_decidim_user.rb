# frozen_string_literal: true

class AddOfficialNameCustomToDecidimUser < ActiveRecord::Migration[5.2]

  def change
    add_column :decidim_users, :official_name_custom, :string
  end

end
