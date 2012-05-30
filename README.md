
Agifog Installation and Configuration
================

Requirements:

* RVM with ruby-1.9.2-p290 (you can install it using: rvm install ruby-1.9.2-p290)
* A set of Dynect credentials for performing DNS operations
* A set of AWS credentials (we use aws-blue for scratching/testing  )

1) Fetch the code and bundle up:

    git clone git@github.com:restebanez/agifog.git
    cd agifog 
    # press y to accept the .rvmrc file
    bundle

2) there are two configuration files that agifog require: __config/.fog__ and __config/dynect.yml__, we can rename the examples files and use them as template

    cp config/.fog-example config/.fog

3) now you have to edit it replacing the X with valid set of was credentials, this is a yaml file so the spaces are important.

    vim config/.fog
    
edit _config/.fog_ replacing the X with valid set of was credentials
    
    :default:
      :aws_access_key_id: XXXXXXXXXXXXXXXXXXXX
      :aws_secret_access_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


4) Same thing with dynect

    cp config/dynect.yml-example config/dynect.yml
    vim config/dynect.yml
    
edit _config/dynect.yml_ replacing the X with valid set of was credentials

    defaults: &defaults
      enabled: true
      customer: mdsol
      username: xxxxxxxxxx
      password: xxxxxxxxx
      zone: imedidata.net
    
    test:
      <<: *defaults
    
    development:
      <<: *defaults
    
    production:
      <<: *defaults


NOTE: Mauth is commented out in development mode so there is no need to worry about this

    config/environments/development.rb
    
    #  config.middleware.use "Medidata::MAuthMiddleware", conf[:mauth_server]

5) let's start the service

    rails s -p 3001

6) Let's test that we can access to AWS from a different console:

    curl localhost:3001/api/v1/rds/servers 

7) let's test that we can access to Dynect

    curl localhost:3001/api/v1/dynect/zones/imedidata.net/

If both tests work, the AgiFog configuration is done. Remember that you have to leave the service running all the time otherwise Agiapp won't work


Run tests
================

    bundle exec rspec

Current problems
================

respond_with doesn't show the json errors. This happens even with rails 3.2.0.rc0. Using render instead

respond_with returns wrong JSON content for errors + AResource documentation bugs
https://github.com/rails/rails/issues/3269

JSON responder should return errors with :errors root
https://github.com/rails/rails/pull/3272 (included in 3.20.rc1)


trying to find where the above pull was done: https://github.com/rails/rails/compare/v3.1.0...v3.1.1
respond_with doesn't show the errors

 -Dont't show it:
  respond_with(:errors => ['it doesn't show it'], :status => 422, :location=> nil)
 - It shows the errors
  render :json => {:errors => ['it shows it']}, :status => 400

