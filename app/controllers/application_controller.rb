class ApplicationController < ActionController::Base
  protect_from_forgery
  
  respond_to :json
  
  require 'fog'
  require 'fog/core/credentials'
  require 'yajl/json_gem' # this is the compatable version


  unless Fog.respond_to?('credentials')
     abort('Please create the .fog file with the right credentials') 
  end

  if Rails.env == 'test'
    puts "Using fog mock in test mode"
    Fog.mock! 
  end
  
  
  def pretty_json_render(body,status=200)
    # render(:json => JSON.pretty_generate(body) # doesn't do it right
    render(:json => JSON.pretty_generate(JSON.parse(body.to_json)), :status => status)
  end

  def rescued_pretty_json_render(rescued_message,status=422)
    if match = rescued_message.message.match(/<Code>(.*)<\/Code>[\s\\\w]+<Message>(.*)<\/Message>/m)
      puts "#{match[1].split('.').last} => #{match[2]}"
      error =  { :errors => ["#{match[1].split('.').last} => #{match[2]}"] }
    else
      error =  { :errors => [rescued_message.message] }
    end
    pretty_json_render(error, status)
  end
  
  protected
  
  def load_params_parsed
    begin
      @params_parsed = JSON.parse(request.raw_post)
    rescue JSON::ParserError
      error =  { :errors => ["The request failed because its format is not valid; it could not be parsed"] }
      pretty_json_render(error, 406) and return # 406 => :not_acceptable
    end
  end
  

end
