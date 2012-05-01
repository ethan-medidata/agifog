class Api::V1::Dynect::NodesController < Api::V1::Dynect::BaseController
  before_filter :load_params_parsed, :only => [:create]
  # https://manage.dynect.net/help/docs/api2/rest/resources/NodeList.html
  
  # GET http://agifog.dev/api/v1/dynect/zones/imedidata.net/nodes/
  # [
  #   "agiapp-sandbox.imedidata.net",
  #   "agifog-sandbox.imedidata.net",
  #   "balance-cruise.imedidata.net",
  #   "balance-hendricks.imedidata.net",
  #   "balance-integration.imedidata.net",
  #   "balance-localization.imedidata.net",
  #   "balance-performance.imedidata.net",
  #   "balance-sandbox.imedidata.net",
  #   "balance-validation.imedidata.net",
  #   "budgets-sandbox.imedidata.net"
  #   ...
  # ]
  def index
    begin
      nodes = dynect.get("NodeList/#{params[:zone_id]}/")
      active_resource_format = nodes.map{|node| {'id' => node}} #active resource expects an array of hashes
      pretty_json_render(active_resource_format)
    rescue => e
      if e.message =~ /NOT_FOUND/
        error = { :errors => ["#{params[:id]} zone not found"] }
        pretty_json_render(error, 404)
      else
        error =  { :errors => [e.message.to_json] }
        pretty_json_render(error, 422)
      end
    end
  end
  
  # GET http://agifog.dev/api/v1/dynect/zones/imedidata.net/nodes/balance-hendricks.imedidata.net
  # [
  #   {
  #     "zone": "imedidata.net",
  #     "ttl": 300,
  #     "fqdn": "balance-hendricks.imedidata.net",
  #     "record_type": "CNAME",
  #     "rdata": {
  #       "cname": "balance-hendricks-app-1423059206.us-east-1.elb.amazonaws.com."
  #     },
  #     "record_id": 11713073
  #   }
  # ]
  
  # GET http://agifog.dev/api/v1/dynect/zones/imedidata.net/nodes/rodrigo.imedidata.net
  # this record has two A entries
  # [
  #   {
  #     "zone": "imedidata.net",
  #     "ttl": 600,
  #     "fqdn": "rodrigo.imedidata.net",
  #     "record_type": "A",
  #     "rdata": {
  #       "address": "192.168.0.1"
  #     },
  #     "record_id": 23070863
  #   },
  #   {
  #     "zone": "imedidata.net",
  #     "ttl": 600,
  #     "fqdn": "rodrigo.imedidata.net",
  #     "record_type": "A",
  #     "rdata": {
  #       "address": "127.0.0.1"
  #     },
  #     "record_id": 23070864
  #   }
  # ]
  
  def show
    begin
      records_url = dynect.get("AllRecord/#{params[:zone_id]}/#{params[:id].sub(/.json$/,'')}")
      records = records_url.map {|r_url| dynect.get("#{r_url.sub(/^\/REST\//, '')}") }
      #raise "there should be only a single record" unless records.size == 1 # active resource only allows one record
      record = records.first
      pretty_json_render(record.merge("id"=>record['fqdn']))
    rescue => e
      if e.message =~ /NOT_FOUND/
        error = { :errors => ["#{params[:id]} zone not found"] }
        pretty_json_render(error, 404)
      else
        error =  { :errors => [e.message.to_json] }
        pretty_json_render(error, 422)
      end
    end
  end
  
  
  #  POST http://agifog.dev/api/v1/dynect/zones/imedidata.net/nodes
  # { "node" : {
  #     "zone": "imedidata.net",
  #     "ttl": 600,
  #     "fqdn": "rodrigo.imedidata.net",
  #     "record_type": "A",
  #     "rdata": "192.168.1.1"
  #    }
  # }
  def create
    begin
      node = @params_parsed["node"]
      node["ttl"] ||= DEFAULT_TTL
      
      case node["record_type"]
      when "A", "a"
        dynect.a.fqdn(node["fqdn"]).ttl(node["ttl"]).address(node["rdata"]).save
      when "CNAME", "cname"
        dynect.cname.fqdn(node["fqdn"]).ttl(node["ttl"]).cname(node["rdata"]).save
      else
        error = { :errors => ["record_type has to be either A or CNAME"] }
        pretty_json_render(error, 400)
      end
      dynect.publish
      pretty_json_render(node,201)
    rescue => e
      rescued_pretty_json_render(e,422)
    end
  end
  
  # https://manage.dynect.net/help/docs/api2/rest/resources/Node.html
  def destroy
    begin
      dynect.delete("Node/#{params[:zone_id]}/#{params[:id].sub(/.json$/,'')}")
      dynect.publish
      pretty_json_render(["#{params[:id]} was deleted successfully"])
    rescue => e
      if e.message =~ /NOT_FOUND/
        error = { :errors => ["#{params[:id]} node not found"] }
        pretty_json_render(error, 404)
      else
        error =  { :errors => [e.message.to_json] }
        pretty_json_render(error, 422)
      end
    end
  end
end