class Api::V1::Iam::UsersController < Api::V1::Iam::BaseController
  before_filter :load_params_parsed, :only => [:create]
  
  def index
    response_with_proper_error do
      users = iam.users or raise Api::Errors::MethodFailure.new("There was a problem retrieving the iam users")
      pretty_json_render(users)
    end
  end
  
  def show
    response_with_proper_error do
      user = iam.users.get(params[:id])
      raise Api::Errors::NotFound.new("#{params[:id]} iam user not found") unless user
      pretty_json_render(user)
    end
  end

  def create
    response_with_proper_error do
      user = iam.users.create(@params_parsed["user"])
      raise Api::Errors::BadRequest.new(user.errors) unless user
      pretty_json_render(user)
    end
  end
  
  def destroy
    response_with_proper_error do
      user = iam.users.get(params[:id]) or raise Api::Errors::NotFound.new("#{params[:id]} iam user not found")
      user.destroy or raise Api::Errors::MethodFailure.new("#{params[:id]} wasn't deleted")
      pretty_json_render(["#{params[:id]} was deleted successfully"])
    end
  end
  
end