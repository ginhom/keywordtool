if Rails.env != 'test'
  email_settings = YAML::load(File.open("#{Rails.root.to_s}/config/email.yml"))
  Keyworkranktool::Application.config.action_mailer.delivery_method = :smtp
  Keyworkranktool::Application.config.action_mailer.smtp_settings = email_settings[Rails.env] unless email_settings[Rails.env].nil?
end