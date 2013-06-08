OmniAuth.config.logger = Rails.logger

CONFIG = YAML.load_file(Rails.root.join('config/facebook.yml'))[Rails.env]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, CONFIG['app_id'], CONFIG['app_secret'], {:scope => 'email, read_stream, read_friendlists'}
 
end