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
        compute.security_groups.create(:name => "servers-agi-sg", :description => "servers-agi-sg desc")
        compute.security_groups.create(:name => "servers-agi-sg-second", :description => "servers-agi-sg-scnd desc")
      
        @ec2_instance = compute.servers.create(:key_name => 'rspec-agi-key', :groups => ['servers-agi-sg'])
        @ec2_instance.wait_for { ready? }
        @last_instance = compute.servers.create(:key_name => 'rspec-agi-key', :groups => ['servers-agi-sg'])
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
    
    describe "DELETE on /api/v1/compute/servers/:id" do

      it "Delete a rds instance" do
        delete "/api/v1/compute/servers/#{@ec2_instance.id}.json"
        last_response.should be_ok
        # verify that doesn't exist anymore
        # This is not the best test because it may take sometime before it's deleted
        # Another option is to list all and if it still shows up, check that is in deleting state
        get "/api/v1/compute/servers/#{@ec2_instance.id}.json"
        if last_response.should be_ok
          attributes = JSON.parse(last_response.body)
          attributes["state"].should == "shutting-down"
        else
          last_response.status.should == 404
        end
      end
    end
    
    describe "POST on /api/v1/compute/servers" do
      
      it "Create an ec2 instance" do
        post "/api/v1/compute/servers.json", {:server => {
            :flavor_id => "m1.small",
            :groups => ["servers-agi-sg", "servers-agi-sg-second"],
            :key_name => 'rspec-agi-key',
            :tags => {'key' => 'value'},
            :availability_zone => "us-east-1a" }
          }.to_json
        last_response.status == 201
        attributes = JSON.parse(last_response.body)
        attributes["flavor_id"].should == "m1.small"
        attributes["availability_zone"].should == "us-east-1a"
        # Fog mocking bug workaround. When using a tag, the state gets to running instead of pending
        %w{pending running}.should include(attributes["state"])
        attributes["groups"].should include("servers-agi-sg")
        attributes["groups"].should include("servers-agi-sg-second")
        attributes["key_name"].should == 'rspec-agi-key'
        attributes["tags"].should == {'key' => 'value'}
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
  
    describe "PUT /api/v1/compute/servers/:server_id/change_status" do
      it "should reboot an ec2 instance" do
        put "/api/v1/compute/servers/#{@last_instance.id}/reboot"
        # i can't really test more than this becasue Fog mocking reboot doesn't work properly
        last_response.should be_ok
      end
      
      # Fog Contributions welcome!
      #it "should stop an ec2 instance" do
      #  put "/api/v1/compute/servers/#{@last_instance.id}/stop"
      #  last_response.should be_ok
      #end
      #
      #it "should start an ec2 instance" do
      #  put "/api/v1/compute/servers/#{@last_instance.id}/start"
      #  last_response.should be_ok
      #end
    end
      
  end
  
end


def compute
  @compute ||= Fog::Compute::AWS.new
end

