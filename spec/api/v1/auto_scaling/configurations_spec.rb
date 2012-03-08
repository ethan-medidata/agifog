require 'spec_helper'


describe "/api/v1/auto_scaling/configurations", :type => :api do
  before(:all) do
    @image = compute.register_image('image', 'image', '/dev/sda1').body
    @image_id = @image['imageId']
  end
  
  it "should return nothing when there isn't any configurations" do
    get '/api/v1/auto_scaling/configurations'
    last_response.should be_ok
    attributes = JSON.parse(last_response.body).should be_empty
  end
  
  describe "listing launch configurations" do
    
    before(:all) do
      @launch_configuration = "first-launch-configuration"
      lc = as.configurations.create(:id => @launch_configuration, :image_id => @image_id, :instance_type => 't1.micro')
      lc = as.configurations.create(:id => 'second-launch-configuration', :image_id => @image_id, :instance_type => 't1.micro')
    end
    
    it "should list every launch configuration" do
      get '/api/v1/auto_scaling/configurations'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      item = attributes.find { |lc| lc['id'] == @launch_configuration }
      item.should_not be_empty
      item["id"].should == @launch_configuration
      item['image_id'].should == @image_id
      item['instance_type'].should == 't1.micro'
      item['security_groups'].should == []
    end
    
    it "should show a launch configuration" do
      get "/api/v1/auto_scaling/configurations/#{@launch_configuration}"
      last_response.should be_ok
      attribute = JSON.parse(last_response.body)
      attribute['id'].should == @launch_configuration
      attribute['image_id'].should == @image_id
      attribute['instance_type'].should == 't1.micro'
      attribute['security_groups'].should == []
    end
    
    it "should return 404 when a launch configuration doesn't exist" do
      get "/api/v1/auto_scaling/configurations/dontexist.json"
      last_response.should_not be_ok
      last_response.status.should == 404
      attributes = JSON.parse(last_response.body)
      attributes["errors"].should == ["dontexist launch configuration not found"]
    end
  end #describe listing
  
  describe "create launch configurations" do
    before(:all) do
      @other_launch_configuration = "rspec-create-configuration"
    end
    
    it "should create a launch configuration" do
      post "/api/v1/auto_scaling/configurations", {:configuration => { 
          :id => @other_launch_configuration,
          :image_id => @image_id,
          :instance_type => "m1.small"}
        }.to_json
      last_response.status == 201
      attributes = JSON.parse(last_response.body)
      attributes['id'].should == @other_launch_configuration
      attributes['image_id'].should == @image_id
      attributes['instance_type'].should == 'm1.small'
      
      # verify that it was created
      get "/api/v1/auto_scaling/configurations/#{@other_launch_configuration}"
      last_response.should be_ok
      attribute = JSON.parse(last_response.body)
      attribute['id'].should == @other_launch_configuration
      attribute['image_id'].should == @image_id
      attribute['instance_type'].should == 'm1.small'
    end
    
    
    it "should fail if all the required params aren't passed" do
      post "/api/v1/auto_scaling/configurations", {:configuration => { 
          :id => @other_launch_configuration,
          :instance_type => "m1.small"}
        }.to_json
      last_response.status == 400
      attributes=JSON.parse(last_response.body)
      attributes["errors"].should == ["image_id is required for this operation"]
    end
  end #describe create
  
  describe "should delete launch configurations" do
    before(:all) do
      @launch_configuration_delete = "rspec-delete-configuration"
      lc = as.configurations.create(:id => @launch_configuration_delete, :image_id => @image_id, :instance_type => 't1.micro')
    end
    
    it "delete an existing launch configuration" do
      delete "/api/v1/auto_scaling/configurations/#{@launch_configuration_delete}"
      last_response.should be_ok
      # verify that it was deleted
      get "/api/v1/auto_scaling/configurations/#{@launch_configuration_delete}"
      last_response.should_not be_ok
      last_response.status.should == 404
    end
  end
end

