class Api::V1::Compute::BaseController < ActionController::Base
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
  
  def compute
    @compute ||= Fog::Compute::AWS.new
  end
  
  def compute_default_server_params
    {
      :key_name=>'agi-develop',
      :groups=>'rodrigo-agi',
      :image_id=>'ami-63be790a'
    }
  end
  
  def pretty_json_render(body,status=200)
    # render(:json => JSON.pretty_generate(body) # doesn't do it right
    render(:json => JSON.pretty_generate(JSON.parse(body.to_json)), :status => status)
  end

end