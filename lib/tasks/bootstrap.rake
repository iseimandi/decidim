namespace :bootstrap do

  # Invocation: bin/rails bootstrap:import_users['/tmp/fake_users.csv']

  desc 'Import users, create records and send invitations'

  task :import_users, [:csv_file_path] => :environment do |t, args|
    path = args[:csv_file_path]

    CSV.foreach(path, { col_sep: ',' }) do |row|

      name = row[0].strip.gsub('-', ' ').split(' ').map { |e| e.capitalize }.join(' ')
      email = row[1].strip.downcase

      puts '------------ Create user ------------'
      puts "Nombre: #{name}"
      puts "Email: #{email}"
      puts '-------------------------------------'

      password = Devise.friendly_token.first(16)

      user = Decidim::User.create!(
        name: name,
        email: email,
        password: password,
        password_confirmation: password,
        organization: Decidim::Organization.first,
        tos_agreement: true,
        confirmed_at: Time.zone.now
      )

      user.send_bootstrap_invitation
    end
  end

end
