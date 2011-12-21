class Api::V1::Rds::ServersController < Api::V1::Rds::BaseController
  def index
    begin
      if @servers = rds.servers
        respond_with(@servers)
      else
        error = { :errors => ["There was a problem retrieving the rds servers"]}
        respond_with(error, :status => 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      respond_with(error, :status => 422)      
    end
  end
  
  
  def show
    begin
      if @server = rds.servers.get(params[:id])
        respond_with(@server)
      else
        error = { :errors => ["#{params[:id]} rds server not found"] }
        respond_with(error, :status => 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      respond_with(error, :status => 422)
    end
  end
  
  def create
    begin
      begin
        new_instance_db = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        respond_with(error, :status => 406) and return
      end
      
      instance_db = rds.servers.create(rds_default_server_params.merge(new_instance_db["server"]))
      if instance_db
        respond_with(instance_db, :location => api_v1_rds_server_path(instance_db))
      else
        error = { :errors => [instance_db.errros] }
        respond_with(error, :status => 401)
      end
    rescue => e
      error =  { :errors => [e.message] }
      respond_with(error, :status => 422)
    end
  end
  
  def destroy
    begin
      @server = rds.servers.get(params[:id])
      raise "#{params[:id]} doesn't exist" unless @server
      if @server.destroy
        respond_with("#{params[:id]} was deleted successfully")
      else        
        error = { :errors => ["#{params[:id]} wasn't deleted"]}
        respond_with(error, :status => 404)
      end
    rescue => e
      error =  { :errors => [e.message] }
      respond_with(error, :status => 422)
    end
  end
  
  def update
    begin
      begin
        modify_options = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        respond_with(error, :status => 406) and return
      end
      
       if @server = rds.servers.get(params[:id])
         modify_options = JSON.parse(request.body.read)
         if @server.modify(false, modify_options)
           respond_with("#{params[:name]} was updated successfully")
         else
           error = { :errors => ["#{params[:id]} wasn't updated"]}
           respond_with(error, :status => 402)
         end
       else
         error = { :errors => ["#{params[:id]} rds server not found"] }
         respond_with(error, :status => 404)    
       end
    rescue => e
     error =  { :errors => [e.message] }
     respond_with(error, :status => 422)
    end
  end
  
end