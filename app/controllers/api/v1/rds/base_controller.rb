class Api::V1::Rds::BaseController < ActionController::Base
  respond_to :json
  
  require 'fog'
  require 'fog/core/credentials'
  require 'yajl/json_gem' # this is the compatable version


  unless Fog.respond_to?('credentials')
     abort('Please create the .fog file with the right credentials') 
  end

#  env_index = ARGV.index("-e")
#  env_arg = ARGV[env_index + 1] if env_index
#  env = env_arg || ENV["SINATRA_ENV"] || "development"
#  if env == 'test'
#    puts "Using fog mock in test mode"
#    Fog.mock! 
#  end
  
  def rds
    @rds ||= Fog::AWS::RDS.new
  end
  
end