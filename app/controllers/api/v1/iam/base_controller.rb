class Api::V1::Iam::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def iam
    @iam ||= Fog::AWS::IAM.new
  end
  
  
  
end