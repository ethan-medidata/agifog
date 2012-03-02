class Api::V1::Compute::BaseController < ApplicationController
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
end