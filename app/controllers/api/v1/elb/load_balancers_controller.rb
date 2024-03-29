class Api::V1::Elb::LoadBalancersController < Api::V1::Elb::BaseController
  before_filter :load_params_parsed, :only => [:create]
  
  def index
    begin
      if @load_balancers = elb.load_balancers
        pretty_json_render(@load_balancers)
      else
        error = { :errors => ["There was a problem retrieving the load balancers"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)      
    end
  end
  
  
  def show
    begin
      if @load_balancer = elb.load_balancers.get(params[:id])
        pretty_json_render(@load_balancer)
      else
        error = { :errors => ["#{params[:id]} load balancer not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def destroy
    begin
      @load_balancer = elb.load_balancers.get(params[:id])
      raise "#{params[:id]} doesn't exist" unless @load_balancer
      if @load_balancer.destroy
        pretty_json_render(["#{params[:id]} was deleted successfully"])
      else        
        error = { :errors => ["#{params[:id]} wasn't deleted"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def create
    begin
      # fog workaround, it ignores string keys
      @load_balancer = elb.load_balancers.create(@params_parsed["load_balancer"].symbolize_keys!)
      if @load_balancer
        pretty_json_render(@load_balancer)
      else
        error = { :errors => [@load_balancer.errors] }
        pretty_json_render(error, 400)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end

end