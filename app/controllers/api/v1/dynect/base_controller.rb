class Api::V1::Dynect::BaseController < ApplicationController
  
  dynect_conf = AppConfig['dynect']
  DYNECT_ZONE = dynect_conf['zone']
  DYNECT_ARGS = [dynect_conf['customer'], dynect_conf['username'], dynect_conf['password'], dynect_conf['zone']]
  DEFAULT_TTL = 600
  
  
  def dynect
    @dynect ||= DynectRest.new(*DYNECT_ARGS)
  end
  
  
end