class Api::V1::Iam::PoliciesController < Api::V1::Iam::BaseController
  before_filter :load_user
  before_filter :load_params_parsed, :only => [:create]
  
  def index
    response_with_proper_error do
      policies = @user.policies or raise Api::Errors::MethodFailure.new("There was a problem retrieving the policies")
      pretty_json_render(policies)
    end
  end
    
  def show
    response_with_proper_error do
      policy = @user.policies.get(params[:id])
      raise Api::Errors::NotFound.new("#{params[:id]} policy not found") unless policy
      pretty_json_render(policy)
    end
  end
  
  def create
    response_with_proper_error do
      policy = @user.policies.create(@params_parsed["policy"])
      raise Api::Errors::BadRequest.new(policy.errors) unless policy
      pretty_json_render(policy)
    end
  end
  
  def destroy
    response_with_proper_error do
      policy = @user.policies.get(params[:id]) or raise Api::Errors::NotFound.new("#{params[:id]} policy not found")
      policy.destroy or raise Api::Errors::MethodFailure.new("#{params[:id]} wasn't deleted")
      pretty_json_render(["#{params[:id]} was deleted successfully"])
    end
  end
  
end