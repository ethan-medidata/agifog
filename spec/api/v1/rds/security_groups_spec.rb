require 'spec_helper'


describe "/api/v1/compute/security_groups", :type => :api do
  it "always includes the default security group" do
    get '/api/v1/rds/security_groups.json'
    last_response.should be_ok
    attributes = JSON.parse(last_response.body)
    instance = JSON.parse(last_response.body).select do |instance| 
      instance['name'].should == 'default'
    end
  end

  describe "basic operations on security groups" do
  
    before(:all) do
      @sec_group_one = {:id => "rspec-agi-sg", :description => "rspec-agi-sg desc"}
      rds.security_groups.create(@sec_group_one)
      @sec_group_second = {:id => "rspec-agi-sg-second", :description => "rspec-agi-sg-scnd desc"}
      rds.security_groups.create(@sec_group_second)
    end
    
    describe "show security groups" do
    
      it "returns every security group" do
        get '/api/v1/rds/security_groups.json'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        instance = JSON.parse(last_response.body).select do |instance| 
          instance['id'] == @sec_group_one[:id]
          instance['description'] == @sec_group_one[:description]
        end
      end
    end
  
    describe "show a specific security group" do
      it "should return a security group" do
        get "/api/v1/rds/security_groups/#{@sec_group_second[:id]}.json"
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes["id"].should == @sec_group_second[:id]
        attributes["description"].should == @sec_group_second[:description]
      end
      
      it "should return 404 when the security group doesn't exist" do
        get "/api/v1/rds/security_groups/dontexist.json"
        last_response.should_not be_ok
        last_response.status.should == 404
        attributes = JSON.parse(last_response.body)
        attributes["errors"].should == ["dontexist rds security group not found"]
      end
    end
  
    describe "creation" do
      
      it "creates a security group successfuly" do
        post "/api/v1/rds/security_groups.json", {:security_group => {
            :id => "new-sg-from-agifog",
            :description => "new security group from agifog" }
          }.to_json
        last_response.status == 201
        attributes = JSON.parse(last_response.body)
        attributes["id"].should == "new-sg-from-agifog"
        attributes["description"].should == "new security group from agifog"
      end
      
      it "fails whith invalid params" do
        post "/api/v1/rds/security_groups.json", {:security_group => {
            :name => "failing-sg-from-agifog",
            :description => "it's not going to work" }
          }.to_json
        last_response.status == 400
        attributes = JSON.parse(last_response.body)
        attributes["errors"].should == ["id is required for this operation"]
      end
      
      it "fails when the data has an invalid json format" do
         post "/api/v1/rds/security_groups.json", '{
             "server": {
                 "id": "bad-formating-sg"
                 "description": "this is gonna fail"
             }
         }'
         last_response.status == 406
         errors = {"errors" => ["The request failed because its format is not valid; it could not be parsed"]}.to_json
         # body has a pretty print json, if you compare it as string it will fail
         last_response.body.should be_json_eql(errors)
      end
    end
  
    describe "delete" do
    end
  end

  
end