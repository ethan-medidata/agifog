class Api::V1::Compute::SecurityGroupsController < Api::V1::Compute::BaseController
  
  before_filter :load_params_parsed, :only => [:create, :authorize, :revoke]
  
  def index
    begin
      if @security_groups = compute.security_groups
        pretty_json_render(@security_groups)
      else
        error = { :errors => ["There was a problem retrieving the security groups"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)      
    end
  end
  
  def show
    begin
      if @security_group = compute.security_groups.get(params[:id])
        pretty_json_render(@security_group)
      else
        error = { :errors => ["#{params[:id]} security group not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def search
    if params[:contains]
      begin
        if @security_groups_matched = compute.security_groups.find_all { |sg| sg.name =~ /#{params[:contains]}/ }
          @security_groups_matched.map!{|sg| sg.send(params[:field]) } if params[:field]
            
          pretty_json_render(@security_groups_matched)
        else
          error = { :errors => ["There was a problem retrieving the security groups"]}
          pretty_json_render(error, 404)
        end
      rescue => e
        rescued_pretty_json_render(e,422)      
      end
    else
      error = { :errors => ["Invalid option, specified search?contains=sg_name"]}
      pretty_json_render(error, 400)
    end
  end
  
  def create
    begin
      security_group = compute.security_groups.create(@params_parsed["security_group"])
      if security_group
        pretty_json_render(security_group)
      else
        error = { :errors => [security_groups.errors] }
        pretty_json_render(error, 400)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  def destroy
    begin
      @security_group = compute.security_groups.get(params[:id])
      raise "#{params[:id]} doesn't exist" unless @security_group
      if @security_group.destroy
        pretty_json_render(["#{params[:id]} was deleted successfully"])
      else        
        error = { :errors => ["#{params[:id]} wasn't deleted"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  #Accpets two sets of params
  # {:network => {  :to_port => mandatory,
  #                 :from_port => mandatory,
  #                 :cidr => optional (default to 0.0.0.0/0)
  #                 :ip_protocol => optional (default to tcp)
  #          }
  #       }
      
  # {:security_group => {:name => mandatory
  #                      :group => nadatory
  #                     }
  #             }
  
  def authorize
    begin
      if @security_group = compute.security_groups.get(params[:id])
        if @params_parsed.key?("security_group")
          authorize_security_group
        elsif @params_parsed.key?("network")
          authorize_network
        else
          error = { :errors => ["It only accepts params contained in either a security_group hash or a network hash"] }
          pretty_json_render(error, 400)
        end
      else
        error = { :errors => ["#{params[:id]} security group not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end  
    
  def revoke
    begin
      if @security_group = compute.security_groups.get(params[:id])
        if @params_parsed.key?("security_group")
          revoke_security_group
        elsif @params_parsed.key?("network")
          revoke_network
        else
          error = { :errors => ["It only accepts params contained in either a security_group hash or a network hash"] }
          pretty_json_render(error, 400)
        end
      else
        error = { :errors => ["#{params[:id]} security group not found"] }
        pretty_json_render(error, 404)
      end
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end



    
  private
  
  def revoke_network
    begin
      network = @params_parsed["network"]
      raise ArgumentError.new "from_port param is required" unless from = network["from_port"] 
      raise ArgumentError.new "to_port param is required" unless to = network["to_port"]
      range = Range.new(*"#{from}..#{to}".split("..").map{|s|s.to_i})
      options = {
        'CidrIp'      => network["cidr"],
        'IpProtocol'  => network["ip_protocol"]
      }
      
      sg = @security_group.revoke_port_range(range, options)
      if sg
        render(:json => ["#{params[:id]} was revoked successfully"])
      else
        error = { :errors => [sg.errors] }
        pretty_json_render(error, 400)
      end
    rescue ArgumentError => e
      rescued_pretty_json_render(e, 406)
    rescue => e
      rescued_pretty_json_render(e, 422)
    end
  end
  
  def revoke_security_group
    begin
      sg_parm = @params_parsed["security_group"]
      raise ArgumentError.new("name param is required") unless group = sg_parm["group"] 
      raise ArgumentError.new("owner param is required") unless owner = sg_parm["owner"]

      sg = @security_group.revoke_group_and_owner(group, owner)
      if sg
        render(:json => ["#{params[:id]} was revoked successfully"])
      else
        error = { :errors => [sg.errors] }
        pretty_json_render(error, 400)
      end
    rescue ArgumentError => e
      rescued_pretty_json_render(e, 406)
    rescue => e
      rescued_pretty_json_render(e, 422)
    end
  end
  
  def authorize_network
    begin
      network = @params_parsed["network"]
      raise ArgumentError.new "from_port param is required" unless from = network["from_port"] 
      raise ArgumentError.new "to_port param is required" unless to = network["to_port"]
      range = Range.new(*"#{from}..#{to}".split("..").map{|s|s.to_i})
      options = {
        'CidrIp'      => network["cidr"],
        'IpProtocol'  => network["ip_protocol"]
      }
      
      sg = @security_group.authorize_port_range(range, options)
      if sg
        render(:json => ["#{params[:id]} was authorized successfully"])
      else
        error = { :errors => [sg.errors] }
        pretty_json_render(error, 400)
      end
    rescue ArgumentError => e
      rescued_pretty_json_render(e, 406)
    rescue => e
      rescued_pretty_json_render(e, 422)
    end
  end
  
  def authorize_security_group
    begin
      sg_parm = @params_parsed["security_group"]
      raise ArgumentError.new("name param is required") unless group = sg_parm["group"] 
      raise ArgumentError.new("owner param is required") unless owner = sg_parm["owner"]

      sg = @security_group.authorize_group_and_owner(group, owner)
      if sg
        render(:json => ["#{params[:id]} was authorized successfully"])
      else
        error = { :errors => [sg.errors] }
        pretty_json_render(error, 400)
      end
    rescue ArgumentError => e
      rescued_pretty_json_render(e, 406)
    rescue => e
      rescued_pretty_json_render(e, 422)
    end
  end
  
  private
    #def compute_security_groups_cache
    #  # expires the cache every 2 minutes
    #  @compute_security_groups_time_to_expire ||= Time.now + 2.minutes
    #  
    #  if @compute_security_groups_time_to_expire < Time.now
    #    @compute_security_groups_time_to_expire = nil 
    #    @compute_security_groups = compute.security_groups        
    #  end
    #  @compute_security_groups ||= compute.security_groups
    #end
  

end