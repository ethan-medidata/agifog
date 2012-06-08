class Api::V1::Iam::AccessKeysController < Api::V1::Iam::BaseController
  before_filter :load_user
  
  def index
    response_with_proper_error do
      access_keys = @user.access_keys or raise Api::Errors::MethodFailure.new("There was a problem retrieving the access keys")
      pretty_json_render(access_keys)
    end
  end
    
  def show
    response_with_proper_error do
      access_key = @user.access_keys.get(params[:id])
      raise Api::Errors::NotFound.new("#{params[:id]} access key not found") unless access_key
      pretty_json_render(access_key)
    end
  end
  
  def create
    response_with_proper_error do
      access_key = @user.access_keys.create
      raise Api::Errors::MethodFailure.new(access_key.errors) unless access_key
      pretty_json_render(access_key)
    end
  end
  
  def destroy
    response_with_proper_error do
      access_key = @user.access_keys.get(params[:id]) or raise Api::Errors::NotFound.new("#{params[:id]} access key not found")
      access_key.destroy or raise Api::Errors::MethodFailure.new("#{params[:id]} wasn't deleted")
      pretty_json_render(["#{params[:id]} was deleted successfully"])
    end
  end
  
end