class Api::V1::AutoScaling::ConfigurationsController < Api::V1::AutoScaling::BaseController
  before_filter :load_params_parsed, :only => [:create]
  
  # http://docs.amazonwebservices.com/AutoScaling/latest/APIReference/API_DescribeLaunchConfigurations.html
  def index
    begin
      if @configurations = as.configurations
        pretty_json_render(@configurations)
      else
        error = { :errors => ["There was a problem retrieving the launch configurations"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)      
    end
  end
  
  def show
    begin
      if @configuration = as.configurations.get(params[:id])
        pretty_json_render(@configuration)
      else
        error = { :errors => ["#{params[:id]} launch configuration not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)
    end
  end
    
  def create
    begin
      @configuration = as.configurations.create(@params_parsed["configuration"])
      if @configuration
        pretty_json_render(@configuration)
      else
        error = { :errors => [@configuration.errors] }
        pretty_json_render(error, 400)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def destroy
    begin
      @configuration = as.configurations.get(params[:id])
      raise "#{params[:id]} doesn't exist" unless @configuration
      if @configuration.destroy
        pretty_json_render(["#{params[:id]} was deleted successfully"])
      else        
        error = { :errors => ["#{params[:id]} wasn't deleted"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
end