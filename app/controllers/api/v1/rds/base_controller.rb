class Api::V1::Rds::BaseController < ActionController::Base
  respond_to :json
  
  require 'fog'
  require 'fog/core/credentials'
  require 'yajl/json_gem' # this is the compatable version


  unless Fog.respond_to?('credentials')
     abort('Please create the .fog file with the right credentials') 
  end

  if Rails.env == 'test'
    puts "Using fog mock in test mode"
    Fog.mock! 
  end
  
  def rds
    @rds ||= Fog::AWS::RDS.new
  end
  
  def rds_default_server_params
    {
      :engine_version => "5.1.57", 
      :allocated_storage => 5, 
      :engine => 'mysql',
      :flavor_id => "db.m1.small", 
      :backup_retention_period => 0 
    }
  end
end