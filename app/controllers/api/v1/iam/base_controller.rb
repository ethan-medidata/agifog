class Api::V1::Iam::BaseController < ApplicationController
 
 private  
   def iam
     @iam ||= Fog::AWS::IAM.new
   end
   
   
   def load_user
     response_with_proper_error do
       @user = iam.users.get(params[:user_id]) or raise Api::Errors::NotFound.new("#{params[:user_id]} iam user not found")
     end
   end
   
end