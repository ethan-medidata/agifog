require 'spec_helper'


describe "/api/v1/compute/servers", :type => :api do
  it "should return an empty array" do
    get '/api/v1/compute/servers.json'
    last_response.should be_ok
    empty_array=[]
    last_response.body.should be_json_eql(empty_array)
  end
  
  describe "Using prepopulated data" do
  
    before(:all) do
        compute.key_pairs.create(:name=>'rspec-agi-key')
        compute.security_groups.create(:name => "rspec-agi-sg", :description => "rspec-agi-sg desc")
        compute.security_groups.create(:name => "rspec-agi-sg-second", :description => "rspec-agi-sg-scnd desc")
      
        puts "Let's create a new ec2_instance"
        @ec2_instance = compute.servers.create(:key_name => 'rspec-agi-key', :groups => ['rspec-agi-sg'])
        puts "Waiting until #{@ec2_instance.id} is ready"
        @ec2_instance.wait_for { ready? }
        puts "Let's create a new ec2_instance"
        @last_instance = compute.servers.create(:key_name => 'rspec-agi-key', :groups => ['rspec-agi-sg'])
        puts "Waiting until #{@last_instance.id} is ready"
        @last_instance.wait_for { ready? }
    end
    
    describe "GET on /api/v1/compute/servers" do
    
      it "should return every ec2 instances" do
        get '/api/v1/compute/servers.json'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        instance = JSON.parse(last_response.body).select do |instance| 
          instance['id'] == @ec2_instance.id
          instance['key_name'] == @ec2_instance.key_name
          instance['groups'] == @ec2_instance.groups
        end
        instance.first["flavor_id"].should match @ec2_instance.flavor_id
      end
    end
    
    describe "GET on /api/v1/compute/servers/:id" do
      it "should return an ec2 instance" do
        get "/api/v1/compute/servers/#{@last_instance.id}"
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes["id"].should == "#{@last_instance.id}"
        attributes["key_name"].should == "#{@last_instance.key_name}"
        attributes["groups"].should == @last_instance.groups
      end
      
      it "should return 404 when the ec2 instance doesn't exist" do
        get "/api/v1/compute/servers/dontexist.json"
        last_response.should_not be_ok
        last_response.status.should == 404
        attributes = JSON.parse(last_response.body)
        attributes["errors"].should == ["dontexist ec2 instance not found"]
      end
    end
    
    describe "POST on /api/v1/compute/servers" do
      
      it "Create an ec2 instance" do
        post "/api/v1/compute/servers.json", {:server => {
            :flavor_id => "m1.small",
            :groups => ["rspec-agi-sg", "rspec-agi-sg-second"],
            :key_name => 'rspec-agi-key',
            :availability_zone => "us-east-1a" }
          }.to_json
        last_response.status == 201
        attributes = JSON.parse(last_response.body)
        attributes["flavor_id"].should == "m1.small"
        attributes["availability_zone"].should == "us-east-1a"
        attributes["state"].should == "pending"
        attributes["groups"].should include("rspec-agi-sg")
        attributes["groups"].should include("rspec-agi-sg-second")
        attributes["key_name"].should == 'rspec-agi-key'
      end
      
      it "Unvalid json format" do
         post "/api/v1/rds/servers.json", '{
             "server": {
                 "flavor_id": "m1.small"
                 "availability_zone": "us-east-1a"
             }
         }'
         last_response.status == 406
         errors = {"errors" => ["The request failed because its format is not valid; it could not be parsed"]}.to_json
         # body has a pretty print json, if you compare it as string it will fail
         last_response.body.should be_json_eql(errors)
      end
    end
  
  end
  
end


def compute
  @compute ||= Fog::Compute::AWS.new
end

