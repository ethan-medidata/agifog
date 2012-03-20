class Api::V1::Dynect::ZonesController < Api::V1::Dynect::BaseController
  
  # https://manage.dynect.net/help/docs/api2/rest/resources/Zone.html
  def index
    begin
      if raw_zones = dynect.get("Zone")
        # ["/REST/Zone/imedidata.net/", "/REST/Zone/mdsoltest.net/"]
        pretty_json_render(raw_zones.map { |z| z.sub(/^\/REST\/Zone\//, '') })
      else
        error = { :errors => ["There was a problem retrieving the dynect zones"]}
        pretty_json_render(error, 404)
      end
    rescue => e
      error =  { :errors => [e.message.to_json] }
      pretty_json_render(error, 422)      
    end
  end
  
    def show
      begin
        zone = dynect.get("Zone/#{params[:id]}")
        pretty_json_render(zone)
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
    
end
