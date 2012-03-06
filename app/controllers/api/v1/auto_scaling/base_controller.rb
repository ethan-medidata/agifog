class Api::V1::AutoScaling::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def as
    @as ||= Fog::AWS::AutoScaling.new
  end
  
  
end