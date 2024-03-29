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
      
      if snapshot_id = new_instance_db["server"].delete("snapshot_id")
        db_identifier = new_instance_db["server"].delete("id")
        opts = {'AvailabilityZone' => new_instance_db["server"]["availability_zone"],
                'MultiAZ' => new_instance_db["server"]["multi_az"],
                'DBInstanceClass' => new_instance_db["server"]["flavor_id"]}
        # there is no model for restore_db_instance_from_db_snapshot
        instance_db = rds.restore_db_instance_from_db_snapshot(snapshot_id, db_identifier, opts)
        # PROBLEM, i can't modify the security groups until the db instance is available, medistrano uses delay job
        #
        #security_group_names = new_instance_db["server"]['security_group_names']
        #if !security_group_names.blank? and security_group_names.join != 'default'
        #  begin
        #    db_server = rds.servers.get(db_identifier)
        #  rescue
        #    raise if @searched_db_instance
        #    @searched_db_instance = true
        #    sleep 1
        #    retry
        #  end
        #  db_server.modify(true,:security_group_names=> security_group_names) # i also tried false
        #end
        
      else
        instance_db = rds.servers.create(rds_default_server_params.merge(new_instance_db["server"]))
      end
      
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
         server = modify_options["server"]
         # this are the attributes that can be modify: 
         # http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/API_ModifyDBInstance.html
         attributes_to_modify = {
            :security_group_names => server['security_group_names'],
            :allocated_storage => server['allocated_storage'],
            :flavor_id => server['flavor_id'],
#            :id => server['id'],
#            :engine_version => server['engine_version'],
#            :parameter_group_name => server['parameter_group_name'],
            :password => server['password'],
            :multi_az => server['multi_az']
            }.reject{|k,v| v.blank? }
                      
         if @server.modify(true,attributes_to_modify)
           render(:json => @server) #this is what update_attributes expects
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