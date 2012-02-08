# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'rack/test'
require 'fog'
require 'fog/core/credentials'

Fog.credentials_path= "config/.fog"
unless Fog.respond_to?('credentials')
   abort('Please create a config/.fog file with the right credentials') 
end

Fog.mock!

def elb
  @elb ||= Fog::AWS::ELB.new
end

def availability_zones
  @availability_zones ||= Fog::Compute[:aws].describe_availability_zones('state' => 'available').body['availabilityZoneInfo'].collect{ |az| az['zoneName'] }
end

def rds
  @rds ||= Fog::AWS::RDS.new
end

def rds_default_server_params
  {
    :id => "test-spec-" + uniq_id,
    :flavor_id => "db.m1.small",
    :db_name => "testspec",
    :security_group_names => ['cloud-rds', 'parley-aarontest'],
    :allocated_storage => 5,
    :engine => 'MySQL',
    :engine_version => "5.1.57",
    :master_username => "testspec",
    :password => "testspec01",
    :multi_az => false,
    :availability_zone => "us-east-1c",
    :backup_retention_period => 0,
    :engine_version => "5.1.57", 
    :allocated_storage => 5, 
    :engine => 'mysql',
    :flavor_id => "db.m1.small", 
  }
end

def uniq_id
  SecureRandom.hex(4)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  
  config.include JsonSpec::Helpers # https://github.com/collectiveidea/json_spec
end
