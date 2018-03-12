require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Attendance
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    dotenv_path = "/home/#{Etc.getlogin}/dotenv/development.env"
    if Rails.env.production?
      dotenv_path = "/home/ubuntu/dotenv/production.env"
    end
    Dotenv.load!("#{dotenv_path}");
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
