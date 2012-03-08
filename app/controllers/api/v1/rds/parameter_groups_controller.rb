class Api::V1::Rds::ParameterGroupsController < Api::V1::Rds::BaseController
  
  # http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/index.html?API_CreateDBInstance.html
  def index
    begin
      if @parameter_groups = rds.parameter_groups
        pretty_json_render(@parameter_groups)
      else
        error = { :errors => ["There was a problem retrieving the parameter groups"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)      
    end
  end
  
    def show
      begin
        if @parameter_group = rds.parameter_groups.get(params[:id])
          pretty_json_render(@parameter_group)
        else
          error = { :errors => ["#{params[:id]} parameter group not found"] }
          pretty_json_render(error, 404)
        end
      rescue => e
        error =  { :errors => [e.message.to_json] }
        pretty_json_render(error, 422)
      end
    end
end