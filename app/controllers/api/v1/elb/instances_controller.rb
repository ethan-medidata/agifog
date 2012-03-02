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
      if @lb = elb.load_balancers.get(params[:load_balancer_id])
        raise ArgumentError.new "instance id is required" unless instance_id = @params_parsed["instance"]["id"]
        enable_availability_zones_if_necesary(instance_id)
        raise "There was a problem registering the instance" unless response = @lb.register_instances(instance_id)
        instances = response.instance_health.make_keys_restful
        instances_result = instances.select { |i| i["id"] == instance_id }
        pretty_json_render(instances_result.first)
      else
        error = { :errors => ["#{params[:load_balancer_id]} load balancer not found"] }
        pretty_json_render(error,404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
        
  def destroy
    begin
      if @lb = elb.load_balancers.get(params[:load_balancer_id])
        raise ArgumentError.new "#{params[:id]} isn't registered" unless @lb.instances.include?(params[:id])
        raise "There was a problem deregistering the instance" unless @lb.deregister_instances(params[:id])
        disable_availability_zones_if_necesary(params[:id])
        pretty_json_render(["#{params[:id]} was deleted successfully"])
      else
        error = { :errors => ["#{params[:id]} load balancer not found"] }
        pretty_json_render(error,404)
      end
    rescue ArgumentError => e
      rescued_pretty_json_render(e,404)
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end      
  
  private
  
  
  def compute
    @compute ||= Fog::Compute::AWS.new
  end
  
  def enable_availability_zones_if_necesary(instance_id)
    # if the instance doesn't exists anymore, it's not possible to know the availability zone so nothing is done
    return false unless instance = compute.servers.get(instance_id)
    @lb.enable_availability_zones(instance.availability_zone) unless @lb.availability_zones.include?(instance.availability_zone)
  end
  
  def disable_availability_zones_if_necesary(instance_id)
    # if the instance doesn't exists anymore, it's not possible to know the availability zone so nothing is done
    return false unless instance = compute.servers.get(instance_id)
     
    # if any of the registered instances belongs to the same availability zone it doesn't have to disable that zone
    registered_instances = @lb.instances
    registered_instances.delete(instance_id)
    registered_instances.each do |i|
      return false if compute.servers.get(i).try(:availability_zone) == instance.availability_zone
    end
    
    @lb.disable_availability_zones(instance.availability_zone) 
  end
end