require 'spec_helper'


describe "/api/v1/rds/servers", :type => :api do
  before(:all) do
    # let's see if we can reuse an existing test-spec instance so we don't have to create it
    instances_db = rds.servers.select{|s| s.id =~ /^test-spec/ && s.state == 'available'}
    if instances_db.empty?
      puts "Let's create a new instance_db"
      @instance_db = rds.servers.create(rds_default_server_params)
      puts "Waiting until #{@instance_db.id} is ready"
      @instance_db.wait_for { ready? }
      puts "Let's create a new instance_db"
      @last_db = rds.servers.create(rds_default_server_params.merge(:id=>'test-spec-last', :db_name=>'otherdb'))
      puts "Waiting until #{@instance_db.id} is ready"
      @last_db.wait_for { ready? }
    elsif
      @instance_db = instances_db.first
      puts "Reusing #{@instance_db.id}"
    end
  end
  
  describe "GET on /api/v1/rds/servers" do
  
    it "should return instances" do
      get '/api/v1/rds/servers.json'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      instance = JSON.parse(last_response.body).select do |instance| 
        instance['id'] == @instance_db.id
      end
      instance.first["flavor_id"].should match @instance_db.flavor_id
    end
  end

  describe "GET on /api/v1/rds/servers/:id" do

    it "should return a db_name" do
      get "/api/v1/rds/servers/test-spec-last.json"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes["id"].should == "test-spec-last"
      attributes["db_name"].should == "otherdb"
    end
    
    it "should return 404 when the instance doesn't exist" do
      get "/api/v1/rds/servers/dontexist.json"
      last_response.should_not be_ok
      last_response.status.should == 404
      attributes = JSON.parse(last_response.body)
      attributes["errors"].should == ["dontexist rds server not found"]
    end

  end
  

  
  describe "PUT on /api/v1/rds/servers/:name.json" do
    
    it "Modifying the security group" do 
      get "/api/v1/rds/servers/#{@instance_db.id}.json"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes["id"].should == @instance_db.id
      modify_options = {:server => { :allocated_storage => 6 }}.to_json 
      put "/api/v1/rds/servers/#{@instance_db.id}.json", modify_options
      put last_response.inspect
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      get "/api/v1/rds/servers/#{@instance_db.id}.json"
      attributes = JSON.parse(last_response.body)
      attributes["pending_modified_values"].should == { "AllocatedStorage"=>6 } # Amazon stores different than fog
    end
  end
       
       

  describe "DELETE on /api/v1/rds/servers/:id" do
    
    it "Delete a rds instance" do
      delete "/api/v1/rds/servers/#{@instance_db.id}.json"
      last_response.should be_ok
      # verify that doesn't exist anymore
      # This is not the best test because it may take sometime before it's deleted
      # Another option is to list all and if it still shows up, check that is in deleting state
      get "/api/v1/rds/servers/#{@instance_db.id}.json"
      last_response.status.should == 404
    end
  end
  
  describe "POST on /api/v1/rds/servers" do
    
    it "Create a rds instance" do
      post "/api/v1/rds/servers.json", {:server => {
          :id => "test-spec-12345",
          :flavor_id => "db.m1.small",
          :db_name => "testspec",
          :allocated_storage => 5,
          :engine => 'MySQL',
          :engine_version => "5.1.57",
          :master_username => "testspec",
          :password => "testspec01",
          :allocated_storage => 5, 
          :engine => 'mysql',
          :flavor_id => "db.m1.small" }
        }.to_json
      last_response.status == 201
      attributes = JSON.parse(last_response.body)
      attributes["id"].should == "test-spec-12345"
      attributes["flavor_id"].should == "db.m1.small"
      attributes["allocated_storage"].should == 5
      # default values when non specifiy
      attributes["db_security_groups"][0]["DBSecurityGroupName"].should == "default"
      attributes["multi_az"].should == false
      attributes["state"].should == "creating"
    end
    
    it "Unvalid json format" do
       post "/api/v1/rds/servers.json", '{
           "server": {
               "id": "test-spec-12347"
               "flavor_id": "db.m1.small",
               db_name: "testspec",
               "allocated_storage": 5,
               "engine": "mysql",
               "engine_version": "5.1.57",
               "master_username": "testspec",
               "password": "testspec01"
           }
       }'
       last_response.status == 406
       errors = {"errors" => ["The request failed because its format is not valid; it could not be parsed"]}.to_json
       # body has a pretty print json, if you compare it as string it will fail
       last_response.body.should be_json_eql(errors)
    end
  end
  
end
    
    
    
def rds
  @rds ||= Fog::AWS::RDS.new
end

def rds_default_server_params
  {
    :id => "test-spec-" + uniq_id,
    :flavor_id => "db.m1.small",
    :db_name => "testspec",
    :security_group_names => ['cloud-rds', 'parley-aarontest'],
    :allocated_storage => 5,
    :engine => 'MySQL',
    :engine_version => "5.1.57",
    :master_username => "testspec",
    :password => "testspec01",
    :multi_az => false,
    :availability_zone => "us-east-1c",
    :backup_retention_period => 0,
    :engine_version => "5.1.57", 
    :allocated_storage => 5, 
    :engine => 'mysql',
    :flavor_id => "db.m1.small", 
  }
end

def uniq_id
  SecureRandom.hex(4)
end