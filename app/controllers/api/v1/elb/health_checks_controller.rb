class Api::V1::Elb::HealthChecksController < Api::V1::Elb::BaseController
  before_filter :load_params_parsed, :only => [:create]
  
  def show
    begin
      if @load_balancer = elb.load_balancers.get(params[:load_balancer_id])
          pretty_json_render(@load_balancer.health_check)
      else
        error = { :errors => ["#{params[:load_balancer_id]} load balancer not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
end