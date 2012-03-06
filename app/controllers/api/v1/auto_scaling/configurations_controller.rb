class Api::V1::AutoScaling::ConfigurationsController < Api::V1::AutoScaling::BaseController
  
  # http://docs.amazonwebservices.com/AutoScaling/latest/APIReference/API_DescribeLaunchConfigurations.html
  def index
    begin
      if @configurations = as.configurations
        pretty_json_render(@configurations)
      else
        error = { :errors => ["There was a problem retrieving the parameter groups"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)      
    end
  end
  

end