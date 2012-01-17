class Api::V1::Elb::BaseController < ApplicationController
  def elb
    @elb ||= Fog::AWS::ELB.new
  end
  
  def availability_zones
    @availability_zones ||= Fog::Compute[:aws].describe_availability_zones('state' => 'available').body['availabilityZoneInfo'].collect{ |az| az['zoneName'] }
  end
  
  def elb_default_server_params
    {
      
    }
  end
end