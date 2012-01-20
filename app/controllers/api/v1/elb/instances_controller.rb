class Api::V1::Elb::InstancesController < Api::V1::Elb::BaseController
  before_filter :load_params_parsed, :only => [:create]
  


  
  def index
    begin
      if @load_balancer = elb.load_balancers.get(params[:load_balancer_id])
        pretty_json_render(@load_balancer.instance_health.make_keys_restful)
      else
        error = { :errors => ["There was a problem retrieving the compute servers"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)      
    end
  end
  
  def show
    begin
      if @load_balancer = elb.load_balancers.get(params[:load_balancer_id])
        instances = @load_balancer.instance_health.make_keys_restful
        instances_result = instances.select { |i| i["id"] == params[:id] }
        if instances_result.empty?
          error = { :errors => ["#{params[:id]} instance not found"] }
          pretty_json_render(error, 404)
        else
          pretty_json_render(instances_result.first)
        end
      else
        error = { :errors => ["#{params[:load_balancer_id]} load balancer not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def create
    begin
      if @lb = elb.load_balancers.get(params[:id])
        raise ArgumentError.new "instance not found" unless instance = compute.servers.get(@params_parsed["instance"]["id"])
        @lb.enable_availability_zones(instance.availability_zone) unless @lb.availability_zones.include?(instance.availability_zone)
        raise "There was a problem registering the instance" unless @lb.register_instances(instance.id)
        # Get and Return current state
        @lb.reload
        instances = @lb.instance_health.make_keys_restful
        instances_result = instances.select { |i| i["id"] == instance.id }
        pretty_json_render(instances_result.first)
      else
        error = { :errors => ["#{params[:id]} load balancer not found"] }
        pretty_json_render(error,404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
        
      
  
  private
  
  

  
  def compute
    @compute ||= Fog::Compute::AWS.new
  end

end