require 'spec_helper'


describe "/api/v1/compute/security_groups", :type => :api do
  it "should return an empty array" do
    get '/api/v1/compute/security_groups.json'
    last_response.should be_ok
    attributes = JSON.parse(last_response.body)
    instance = JSON.parse(last_response.body).select do |instance| 
      instance['name'].should == 'default'
    end
  end
  
  describe "Using prepopulated data" do
  
    before(:all) do
      @sec_group_one = {:name => "rspec-agi-sg", :description => "rspec-agi-sg desc"}
      compute.security_groups.create(@sec_group_one)
      @sec_group_second = {:name => "rspec-agi-sg-second", :description => "rspec-agi-sg-scnd desc"}
      compute.security_groups.create(@sec_group_second)
      
    end
    
    describe "GET on /api/v1/compute/security_groups" do
    
      it "should return every ec2 instances" do
        get '/api/v1/compute/security_groups.json'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        instance = JSON.parse(last_response.body).select do |instance| 
          instance['name'] == @sec_group_one[:name]
          instance['description'] == @sec_group_one[:description]
        end
      end
    end
    
    describe "GET on /api/v1/compute/security_groups/:id" do
      it "should return an ec2 instance" do
        get "/api/v1/compute/security_groups/#{@sec_group_second[:name]}.json"
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes["name"].should == @sec_group_second[:name]
        attributes["description"].should == @sec_group_second[:description]
      end
      
      it "should return 404 when the ec2 instance doesn't exist" do
        get "/api/v1/compute/security_groups/dontexist.json"
        last_response.should_not be_ok
        last_response.status.should == 404
        attributes = JSON.parse(last_response.body)
        attributes["errors"].should == ["dontexist security group not found"]
      end
    end
    
    describe "POST on /api/v1/compute/security_groups" do
      
      it "Create a security group" do
        post "/api/v1/compute/security_groups.json", {:security_group => {
            :name => "new-sg-from-agifog",
            :description => "new security group from agifog" }
          }.to_json
        last_response.status == 201
        attributes = JSON.parse(last_response.body)
        attributes["name"].should == "new-sg-from-agifog"
        attributes["description"].should == "new security group from agifog"
      end
      
      it "Invalid params" do
        post "/api/v1/compute/security_groups.json", {:security_group => {
            :id => "failing-sg-from-agifog",
            :description => "it's not going to work" }
          }.to_json
        last_response.status == 400
        attributes = JSON.parse(last_response.body)
        attributes["errors"].should == ["name is required for this operation"]
      end
      
      it "Invalid json format" do
         post "/api/v1/rds/security_groups.json", '{
             "server": {
                 "name": "bad-formating-sg"
                 "description": "this is gonna fail"
             }
         }'
         last_response.status == 406
         errors = {"errors" => ["The request failed because its format is not valid; it could not be parsed"]}.to_json
         # body has a pretty print json, if you compare it as string it will fail
         last_response.body.should be_json_eql(errors)
      end
    end
    
    describe "DELETE on /api/v1/security_groups/servers/:id" do

      it "Delete a rds instance" do
        delete "/api/v1/compute/security_groups/#{@sec_group_one[:name]}.json"
        last_response.should be_ok
        # verify that doesn't exist anymore
        # This is not the best test because it may take sometime before it's deleted
        # Another option is to list all and if it still shows up, check that is in deleting state
        get "api/v1/compute/security_groups/#{@sec_group_one[:name]}.json"
        last_response.status.should == 404
      end
    end
  end
    
  describe "Authorizations in a security group" do
      before(:all) do
        @sec_group = {:name => "spec-sg-authorize", :description => "sg for testing authorization and revoking"}
        compute.security_groups.create(@sec_group)
      end
      
      it "only accepts params contained in either a security_group hash or a network hash" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/authorize.json", {:non_accepted_hash => {
            :name => "default",
            :owner => "0123456" }
          }.to_json
        last_response.status.should == 400
        errors = {"errors" => ["It only accepts params contained in either a security_group hash or a network hash"]}.to_json
         last_response.body.should be_json_eql(errors)
      end
      
      it "Authorize a ec2 security group" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/authorize.json", {:security_group => {
            :group => "default",
            :owner => "0123456" }
          }.to_json
        last_response.status.should == 200
        last_response.body.should be_json_eql(["#{@sec_group[:name]} was authorized successfully"])
      end
      
      it "Authorize ssh port with valid params" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/authorize.json", {:network => {
            :cidr => "0.0.0.0/0",
            :from_port => "22",
            :to_port => "22",
            :ip_protocol => "tcp" }
          }.to_json
        last_response.status.should == 200
        last_response.body.should be_json_eql(["#{@sec_group[:name]} was authorized successfully"])
      end
      
      it "Authorize ssh port with missing params" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/authorize.json", {:network => {
            :cidr => "0.0.0.0/0",
            :to_port => "22",
            :ip_protocol => "tcp" }
          }.to_json
        last_response.status.should == 406
        errors = {"errors" => ["from_port param is required"]}.to_json
        last_response.body.should be_json_eql(errors)
      end
      
  end
  
  
  describe "Revoking permission in a security group" do
      before(:all) do
        @sec_group = {:name => "spec-sg-for-revoking", :description => "sg for testing authorization and revoking"}
        sg = compute.security_groups.create(@sec_group)
        sg.authorize_port_range(20..21, :cidr_ip => '0.0.0.0/0', :ip_protocol => 'tcp')
        sg.authorize_group_and_owner('default','0123456')
      end
      
      it "only accepts params contained in either a security_group hash or a network hash" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/revoke.json", {:non_accepted_hash => {
            :name => "default",
            :owner => "0123456" }
          }.to_json
        last_response.status.should == 400
        errors = {"errors" => ["It only accepts params contained in either a security_group hash or a network hash"]}.to_json
        last_response.body.should be_json_eql(errors)
      end
      
      it "Authorize a ec2 security group" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/revoke.json", {:security_group => {
            :group => "default",
            :owner => "0123456" }
          }.to_json
        last_response.status.should == 200
        last_response.body.should be_json_eql(["#{@sec_group[:name]} was revoked successfully"])
      end
      
      it "Authorize ssh port with valid params" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/revoke.json", {:network => {
            :cidr => "0.0.0.0/0",
            :from_port => "20",
            :to_port => "21",
            :ip_protocol => "tcp" }
          }.to_json
        last_response.status.should == 200
        last_response.body.should be_json_eql(["#{@sec_group[:name]} was revoked successfully"])
      end
      
      it "Authorize ssh port with missing params" do
        put "/api/v1/compute/security_groups/#{@sec_group[:name]}/revoke.json", {:network => {
            :cidr => "0.0.0.0/0",
            :to_port => "21",
            :ip_protocol => "tcp" }
          }.to_json
        last_response.status.should == 406
        errors = {"errors" => ["from_port param is required"]}.to_json
        last_response.body.should be_json_eql(errors)
      end
      
  end
  
end



def compute
  @compute ||= Fog::Compute::AWS.new
end