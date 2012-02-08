class Api::V1::Rds::SecurityGroupsController < Api::V1::Rds::BaseController
  
  #http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/index.html?API_CreateDBInstance.html
  def index
    begin
      if @security_groups = rds.security_groups
        render(:json => @security_groups)
#        render(:json => JSON.pretty_generate(JSON.parse(@security_groups.to_json)))
      else
        error = { :errors => ["There was a problem retrieving the rds security_groups"]}
        render(:json => error, :status => 404)
      end
    rescue => e
      if match = e.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
        puts "#{match[1].split('.').last} => #{match[2]}"
        error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
      else
        error =  { :errors => [e.message] }
      end
      render(:json => error, :status => 422)
    end
  end
  
  def show
    begin
      if @security_group = rds.security_groups.get(params[:id])
        render(:json => @security_group)
      else
        error = { :errors => ["#{params[:id]} rds security group not found"] }
        render(:json => error, :status => 404)
      end
    rescue => e
      if match = e.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
        puts "#{match[1].split('.').last} => #{match[2]}"
        error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
      else
        error =  { :errors => [e.message] }
      end
      render(:json => error, :status => 422)
    end
  end
  
  def create
    begin
      begin
        new_security_group = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        render(:json => error, :status => 406) and return # 406 => :not_acceptable
      end
      
      security_group = rds.security_groups.create(new_security_group["security_group"])
      if security_group
        render(:json => security_group, :location => api_v1_rds_security_group_path(security_group))
      else
        error = { :errors => [security_group.errros] }
        render(:json => error, :status => 400)
      end
    rescue => e
      if match = e.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
        puts "#{match[1].split('.').last} => #{match[2]}"
        error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
      else
        error =  { :errors => [e.message] }
      end
      render(:json => error, :status => 422)
    end
  end
  
  def destroy
    begin
      @security_group = rds.security_groups.get(params[:id])
      raise "#{params[:id]} doesn't exist" unless @security_group
      if @security_group.destroy
        render(:json => ["#{params[:id]} was deleted successfully"])
      else        
        error = { :errors => ["#{params[:id]} wasn't deleted"]}
        render(:json => error, :status => 404)
      end
    rescue => e
      if match = e.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
        puts "#{match[1].split('.').last} => #{match[2]}"
        error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
      else
        error =  { :errors => [e.message] }
      end
      render(:json => error, :status => 422)
    end
  end
  
  def revoke
    begin
      begin
        opts = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        render(:json => error, :status => 406) and return
      end
      
      if @security_group = rds.security_groups.get(params[:id])
        if opts.key?("cidr")
          if @security_group.revoke_cidrip(opts["cidr"])
            render(:json => ["#{params[:id]} was authorized successfully"])
          else
            raise "Failed to authorize cidrip"
          end 
        elsif opts.key?("ec2name")
          if @security_group.revoke_ec2_security_group(opts["ec2name"],opts["ec2owner"])
            render(:json => ["#{params[:id]} was authorized successfully"])
          else 
            raise "Failed to authorize ec2 sec group" 
          end
        end
      else
        error = { :errors => ["#{params[:id]} rds security group not found"] }
        render(:json => error, :status => 404)    
      end
      
    rescue => e
      if match = e.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
        puts "#{match[1].split('.').last} => #{match[2]}"
        error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
      else
        error =  { :errors => [e.message] }
      end
      render(:json => error, :status => 422)
    end
  end
  
  def authorize
    begin
      begin
        opts = JSON.parse(request.raw_post)
      rescue JSON::ParserError
        error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
        render(:json => error, :status => 406) and return
      end
      
      if @security_group = rds.security_groups.get(params[:id])
        if opts.key?("cidr")
          if @security_group.authorize_cidrip(opts["cidr"])
            render(:json => ["#{params[:id]} was authorized successfully"])
          else
            raise "Failed to authorize cidrip"
          end 
        elsif opts.key?("ec2name")
          if @security_group.authorize_ec2_security_group(opts["ec2name"],opts["ec2owner"])
            render(:json => ["#{params[:id]} was authorized successfully"])
          else 
            raise "Failed to authorize ec2 sec group" 
          end
        end
      else
        error = { :errors => ["#{params[:id]} rds security group not found"] }
        render(:json => error, :status => 404)    
      end
      
    rescue => e
      if match = e.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
        puts "#{match[1].split('.').last} => #{match[2]}"
        error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
      else
        puts e.message
        error =  { :errors => [e.message] }
      end
      render(:json => error, :status => 422)
    end
  end
  
end