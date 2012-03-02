class Api::V1::Rds::ServersController < Api::V1::Rds::BaseController
  
  #http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/index.html?API_CreateDBInstance.html
  def index
    begin
      if @servers = rds.servers
        pretty_json_render(@servers)
      else
        error = { :errors => ["There was a problem retrieving the rds servers"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)      
    end
  end
  
  
  def show
    begin
      if @server = rds.servers.get(params[:id])
        pretty_json_render(@server)
      else
        error = { :errors => ["#{params[:id]} rds server not found"] }
        
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
        new_instance_db = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        pretty_json_render(error, 406) and return # 406 => :not_acceptable
      end
      
      instance_db = rds.servers.create(rds_default_server_params.merge(new_instance_db["server"]))
      if instance_db
        render(:json => instance_db, :location => api_v1_rds_server_path(instance_db))
      else
        error = { :errors => [instance_db.errros] }
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
  
  def destroy
    begin
      @server = rds.servers.get(params[:id])
      raise "#{params[:id]} doesn't exist" unless @server
      if @server.destroy
        render(:json => ["#{params[:id]} was deleted successfully"])
      else        
        error = { :errors => ["#{params[:id]} wasn't deleted"]}
        pretty_json_render(error, 404)
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
  
  def update
    begin
      begin
        modify_options = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        pretty_json_render(error, 406) and return
      end
      
       if @server = rds.servers.get(params[:id])
         modify_options = JSON.parse(request.body.read)
         if @server.modify(false, modify_options)
           render(:json => ["#{params[:id]} was updated successfully"])
         else
           error = { :errors => ["#{params[:id]} wasn't updated"]}
           pretty_json_render(error, 400)
         end
       else
         error = { :errors => ["#{params[:id]} rds server not found"] }
         pretty_json_render(error, 404)    
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