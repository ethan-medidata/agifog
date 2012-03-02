require 'spec_helper'

describe "/api/v1/elb/load_balancers/:load_balancer_id/instances", :type => :api do

  before(:all) do    
    @elb_one = elb.load_balancers.create(:id => 'rspec-test-one', :availability_zones => availability_zones)
    @elb_one.wait_for { ready? }

    
    @ec2_instance_one_a = Fog::Compute[:aws].servers.create(:availability_zone =>'us-east-1a')
    @ec2_instance_one_a.wait_for { ready? }
    @ec2_instance_one_b = Fog::Compute[:aws].servers.create(:availability_zone =>'us-east-1b')
    @ec2_instance_one_b.wait_for { ready? }
  end
  
  after(:all) do
    @elb_one.destroy
    @ec2_instance_one_a.destroy
    @ec2_instance_one_b.destroy
  end
    
  
  it "a new load balancer doesn't have instances" do
    get "/api/v1/elb/load_balancers/#{@elb_one.id}/instances"
    last_response.should be_ok
    empty_array=[]
    last_response.body.should be_json_eql(empty_array)
  end
  
  describe "show instances attached to a load balancer" do
    before(:all) do
      begin
        @elb_one.register_instances(@ec2_instance_one_a.id)
        @elb_one.register_instances(@ec2_instance_one_b.id)
      rescue Fog::AWS::ELB::InvalidInstance
        # It may take a moment for a newly created instances to be visible to ELB requests
        raise if @retried_registered_instance
        @retried_registered_instance = true
        sleep 1
        retry
      end
    end
    
    it "shows all the instances attached to a load balancer" do
      get "/api/v1/elb/load_balancers/#{@elb_one.id}/instances"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes.size.should == 2
    end
    
    it "shows information about a specifc instance attached to a load balancer" do
      get "/api/v1/elb/load_balancers/#{@elb_one.id}/instances/#{@ec2_instance_one_a.id}"
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes["id"].should == @ec2_instance_one_a.id
      %w{OutOfService InService}.should include(attributes["state"])
      attributes["description"].should == ""
      attributes["reason_code"].should == ""
    end
  end
  
  describe "register and deregister instances" do
    before(:all) do
      # enable_availability_zones mocking doesn't work so i can't test if it really adds the availability_zones
      @elb_two = elb.load_balancers.create(:id => 'rspec-test-two', :availability_zones => availability_zones)
      @elb_two.wait_for { ready? }
    end
    
    after(:all) do
      @elb_two.destroy
    end
      
    
    it "attaches an instance to a load balancer" do
      post "/api/v1/elb/load_balancers/#{@elb_two.id}/instances", {:instance => {:id => @ec2_instance_one_a.id}}.to_json
      last_response.status == 201
      attributes = JSON.parse(last_response.body)
      attributes["id"].should == @ec2_instance_one_a.id
      %w{OutOfService InService}.should include(attributes["state"])
      attributes["description"].should == ""
      attributes["reason_code"].should == ""
      
      get "/api/v1/elb/load_balancers/#{@elb_two.id}/instances/#{@ec2_instance_one_a.id}"
      last_response.should be_ok
    end
    
    it "detaches an instance from a load balancer" do
      delete "/api/v1/elb/load_balancers/#{@elb_two.id}/instances/#{@ec2_instance_one_a.id}"
      last_response.should be_ok
      
      get "/api/v1/elb/load_balancers/#{@elb_two.id}/instances/#{@ec2_instance_one_a.id}"
      last_response.status == 404
    end
    
    it "fails when try to detach an instance not attached" do
      delete "/api/v1/elb/load_balancers/#{@elb_two.id}/instances/#{@ec2_instance_one_a.id}"
      last_response.status == 404
      errors = {"errors" => ["#{@ec2_instance_one_a.id} isn't registered"]}.to_json
      last_response.body.should be_json_eql(errors)
    end
  end
  
  
end

