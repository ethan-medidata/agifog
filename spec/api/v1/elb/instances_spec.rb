require 'spec_helper'

describe "/api/v1/elb/load_balancers/:load_balancer_id/instances", :type => :api do

  before(:all) do    
    @elb_one = elb.load_balancers.create(:id => 'rspec-test-one', :availability_zones => availability_zones)
    @elb_one.wait_for { ready? }
    @elb_two = elb.load_balancers.create(:id => 'rspec-test-two', :availability_zones => availability_zones)
    @elb_two.wait_for { ready? }
    
    @server_one = Fog::Compute[:aws].servers.create
    @server_one.wait_for { ready? }
    @server_two = Fog::Compute[:aws].servers.create
    @server_two.wait_for { ready? }
  end
  
  it "GET /api/v1/elb/load_balancers/:load_balancer_id/instances should be empty" do
    get "/api/v1/elb/load_balancers/#{@elb_one.id}/instances"
    last_response.should be_ok
    empty_array=[]
    last_response.body.should be_json_eql(empty_array)
  end
  
  describe "show instances attach to a load balancer" do
    before(:all) do
      begin
        @elb_one.register_instances(@server_one.id)
        @elb_one.register_instances(@server_two.id)
      rescue Fog::AWS::ELB::InvalidInstance
        # It may take a moment for a newly created instances to be visible to ELB requests
        raise if @retried_registered_instance
        @retried_registered_instance = true
        sleep 1
        retry
      end
    end
    
    it "GET /api/v1/elb/load_balancers/:load_balancer_id/instances" do
      get "/api/v1/elb/load_balancers/#{@elb_one.id}/instances"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes.size.should == 2
    end
    
    it "GET /api/v1/elb/load_balancers/:load_balancer_id/instances/:id" do
      get "/api/v1/elb/load_balancers/#{@elb_one.id}/instances/#{@server_one.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes["id"].should == @server_one.id
      %w{OutOfService InService}.should include(attributes["state"])
      attributes["description"].should == ""
      attributes["reason_code"].should == ""
    end
  end
  
  describe "register and deregister instances" do
    it "POST on /api/v1/elb/load_balancers/:load_balancer_id/instances" do
      post "/api/v1/elb/load_balancers/#{@elb_two.id}/instances", {:instance => {:id => @server_one.id}}.to_json
      last_response.status == 201
      attributes = JSON.parse(last_response.body)
      attributes["id"].should == @server_one.id
      %w{OutOfService InService}.should include(attributes["state"])
      attributes["description"].should == ""
      attributes["reason_code"].should == ""
    end
  end
end

