class Api::V1::Compute::ServersController < Api::V1::Compute::BaseController
  
  def index
    begin
      if @servers = compute.servers
        pretty_json_render(@servers)
      else
        error = { :errors => ["There was a problem retrieving the compute servers"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)      
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
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)
    end
  end
    
  def create
    begin
      begin
        new_ec2_instance = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        pretty_json_render(error, 406) and return # 406 => :not_acceptable
      end
  
      ec2_instance = compute.servers.create(compute_default_server_params.merge(new_ec2_instance["server"]))
      if ec2_instance
        render(:json => ec2_instance, :location => api_v1_compute_server_path(ec2_instance))
      else
        error = { :errors => [ec2_instance.errros] }
        pretty_json_render(error, 400)
      end
    rescue => e
      if match = e.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
        puts "#{match[1].split('.').last} => #{match[2]}"
        error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
      else
        error =  { :errors => [e.message] }
      end
      pretty_json_render(error, 422)
    end
  end  
end
