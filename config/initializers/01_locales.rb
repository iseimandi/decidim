I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{yml}')]
I18n.available_locales = [:ca, :es]
I18n.default_locale = :ca
