# frozen_string_literal: true

class AddTelephoneNumberCustomToDecidimUser < ActiveRecord::Migration[5.2]

  def change
    add_column :decidim_users, :telephone_number_custom, :string
  end

end
