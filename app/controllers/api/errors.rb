module Api
  module Errors
    class Error < StandardError; end
    
    class NotFound < Api::Errors::Error; end
    
    class BadRequest < Api::Errors::Error; end
    
    class MethodFailure < Api::Errors::Error; end
  end
end