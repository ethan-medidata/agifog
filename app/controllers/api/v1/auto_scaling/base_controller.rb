class Api::V1::AutoScaling::BaseController < ApplicationController
  
  def as
    @as ||= Fog::AWS::AutoScaling.new
  end
  
  
end