class Api::V1::Iam::UsersController < Api::V1::Iam::BaseController
  before_filter :load_params_parsed, :only => [:create]
  
  def index
    begin
      if users = iam.users
        pretty_json_render(users)
      else
        error = { :errors => ["There was a problem retrieving the iam users"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)      
    end
  end
  
  def show
    begin
      if user = iam.users.get(params[:id])
        pretty_json_render(user)
      else
        error = { :errors => ["#{params[:id]} iam user not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)
    end
  end

  def create
    begin
      user = iam.users.create(@params_parsed["user"])
      if user
        pretty_json_render(user)
      else
        error = { :errors => [user.errors] }
        pretty_json_render(error, 400)
      end
    rescue Fog::AWS::IAM::EntityAlreadyExists => e
      rescued_pretty_json_render(e, 409)
    rescue => e
      rescued_pretty_json_render(e, 422)
    end
  end
  
  def destroy
    begin
      user = iam.users.get(params[:id])
      raise Fog::AWS::IAM::NotFound.new("#{params[:id]} iam user not found") unless user
      if user.destroy
        pretty_json_render(["#{params[:id]} was deleted successfully"])
      else        
        error = { :errors => ["#{params[:id]} wasn't deleted"]}
        pretty_json_render(error, 404)
      end
    rescue Fog::AWS::IAM::NotFound => e  
      rescued_pretty_json_render(e,404)
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
end