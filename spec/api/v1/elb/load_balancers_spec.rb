require 'spec_helper'

describe "/api/v1/elb/load_balancers", :type => :api do
  it "should return an empty array" do
    get '/api/v1/elb/load_balancers.json'
    last_response.should be_ok
    empty_array=[]
    last_response.body.should be_json_eql(empty_array)
  end
  
  describe "Using prepopulated data" do
  
    before(:all) do
        @elb_one = elb.load_balancers.create(:id => 'rspec-test', :availability_zones => availability_zones)
        @elb_one.wait_for { ready? }
    end
    
    describe "GET on /api/v1/elb/load_balancers" do
    
      it "should return every loadbalancer" do
        get '/api/v1/elb/load_balancers.json'
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        instance = JSON.parse(last_response.body).select do |load_balancer| 
          load_balancer['availability_zones'] == @elb_one.availability_zones
          load_balancer['instances'] == []
          load_balancer['id'] == @elb_one.id
        end
      end
    end
    
    describe "GET on /api/v1/elb/load_balancers/:id.json" do
      it "should return a load balancer" do
        get "/api/v1/elb/load_balancers/#{@elb_one.id}.json"
        last_response.should be_ok
        attributes = JSON.parse(last_response.body)
        attributes["id"].should == @elb_one.id
        attributes["instances"].should == []
        attributes["ListenerDescriptions"].first["Listener"]["LoadBalancerPort"].should == 80
        attributes["ListenerDescriptions"].first["Listener"]["InstancePort"].should == 80
      end
      
      it "should return 404 when the load balancer doesn't exist" do
        get "/api/v1/elb/load_balancers/dontexist.json"
        last_response.should_not be_ok
        last_response.status.should == 404
        attributes = JSON.parse(last_response.body)
        attributes["errors"].should == ["dontexist load balancer not found"]
      end
    end
    
    describe "DELETE on /api/v1/elb/load_balancers/:id.json" do

      it "Delete a load balancer" do
        delete "/api/v1/elb/load_balancers/#{@elb_one.id}.json"
        last_response.should be_ok
        # verify that doesn't exist anymore
        # This is not the best test because it may take sometime before it's deleted
        # Another option is to list all and if it still shows up, check that is in deleting state
        get "/api/v1/elb/load_balancers/#{@elb_one.id}.json"
        last_response.status.should == 404
      end
    end
  end
  
end

def elb
  @elb ||= Fog::AWS::ELB.new
end

def availability_zones
  @availability_zones ||= Fog::Compute[:aws].describe_availability_zones('state' => 'available').body['availabilityZoneInfo'].collect{ |az| az['zoneName'] }
end