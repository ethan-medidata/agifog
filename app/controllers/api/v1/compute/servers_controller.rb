class Api::V1::Compute::ServersController < Api::V1::Compute::BaseController
  
  before_filter :load_params_parsed, :only => [:create]
  
  
  def index
    begin
      if @servers = compute.servers
        pretty_json_render(@servers)
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
      if @server = compute.servers.get(params[:id])
        pretty_json_render(@server)
      else
        error = { :errors => ["#{params[:id]} ec2 instance not found"] }

#        This is wrong, as it expects { "errors": { "name": ["Name cannot be empty"] } }.
#        There is also pull request for this to patch the tests, but documentation remains in old state.
#        https://github.com/odorcicd/rails/commit/b09b2a8401c18d1efff21b3919ac280470a6eb8b
#        error = { :errors => {:name => ["#{params[:id]} rds server not found"]} }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def reboot
    begin
      if @server = compute.servers.get(params[:id])
        @server.reboot
        pretty_json_render(true)
      else
        error = { :errors => ["#{params[:id]} ec2 instance not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def start
    begin
      if @server = compute.servers.get(params[:id])
        @server.start
        pretty_json_render(true)
      else
        error = { :errors => ["#{params[:id]} ec2 instance not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def stop
    begin
      if @server = compute.servers.get(params[:id])
        @server.stop
        pretty_json_render(true)
      else
        error = { :errors => ["#{params[:id]} ec2 instance not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
    
  def create
    begin
      ec2_instance = compute.servers.create(compute_default_server_params.merge(@params_parsed["server"]))
      if ec2_instance
        render(:json => ec2_instance, :location => api_v1_compute_server_path(ec2_instance))
      else
        error = { :errors => [ec2_instance.errors] }
        pretty_json_render(error, 400)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def destroy
    begin
      @server = compute.servers.get(params[:id])
      raise "#{params[:id]} doesn't exist" unless @server
      if @server.destroy
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
