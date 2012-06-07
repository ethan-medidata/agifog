class Api::V1::Iam::BaseController < ApplicationController
 
 private  
   def iam
     @iam ||= Fog::AWS::IAM.new
   end
   
   
   def load_user
     @user = iam.users.get(params[:user_id])
   end
   
end