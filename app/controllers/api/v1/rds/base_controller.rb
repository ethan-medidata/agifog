class Api::V1::Rds::BaseController < ApplicationController
  
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