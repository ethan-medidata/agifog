require File.expand_path('../boot', __FILE__)

#require 'rails/all'
require "action_controller/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"
# http://pivotallabs.com/users/jdean/blog/articles/1419-building-a-fast-lightweight-rest-service-with-rails-3-

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Agifog
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    mauth_config = YAML.load_file(File.join(Rails.root, "config/mauth.yml"))[Rails.env]
    mauth_config['logger'] = Rails.logger
    require 'mauth/rack'
    config.middleware.use MAuth::Rack::ResponseSigner, mauth_config
    # authenticate all requests except /app_status with MAuth
    config.middleware.use MAuth::Rack::RequestAuthenticatorNoAppStatus, mauth_config

    require 'eureka-client'
    eureka_config = YAML.load_file('config/eureka.yml')[Rails.env]
    eureka_config['mauth_config'] = mauth_config
    eureka_config['logger'] = Rails.logger
    agifog_api = YAML.load_file(Rails.root.join('config/api_document.yml'))
    eureka_client = Eureka::Client.new(eureka_config)

    eureka_client.deploy_apis!([agifog_api])
  end
end
