class Api::V1::Compute::SecurityGroupsController < Api::V1::Compute::BaseController
  
  before_filter :load_params_parsed, :only => [:create, :authorize]
  
  def index
    begin
      if @security_groups = compute.security_groups
        pretty_json_render(@security_groups)
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
  # {:network => { :to_port => mandatory,
  #           :from_port => mandatory,
  #           :cidr => optional (default to 0.0.0.0/0)
  #           :protocol => optional (default to tcp)
  #          }
  #       }
      
  # {:security_group => {:name => mandatory
  #                      :group => nadatory
  #                     }
  #             }
  
  #def authorize
  #  begin
  #    if @security_group = compute.security_groups.get(params[:id])
  #      if @params_parsed.key?("network")
  #        # translate rest params to fog params
  #         
  #        if @security_group.authorize_cidrip(@params_parsed["cidr"])
  #          pretty_json_render(["#{params[:id]} was authorized successfully"])
  #        else
  #          raise "Failed to authorize cidrip"
  #        end 
  #      elsif @params_parsed.key?("security_group")
  #        if @security_group.authorize_ec2_security_group(@params_parsed["ec2name"],@params_parsed["ec2owner"])
  #          pretty_json_render(["#{params[:id]} was authorized successfully"])
  #        else 
  #          raise "Failed to authorize ec2 sec group" 
  #        end
  #      else
  #        raise "It only accetps tow sets of data: Network or Security Group"
  #      end
  #    else
  #      error = { :errors => ["#{params[:id]} security group not found"] }
  #      pretty_json_render(error, 404)   
  #    end
  #    
  #  rescue => e
  #    rescued_pretty_json_render(e,422)
  #  end
  #end
end