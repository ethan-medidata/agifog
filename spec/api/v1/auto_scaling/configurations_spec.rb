require 'spec_helper'


describe "/api/v1/auto_scaling/configurations", :type => :api do
  it "should return nothing when there isn't any configurations" do
    get '/api/v1/auto_scaling/configurations'
    last_response.should be_ok
    attributes = JSON.parse(last_response.body).should be_empty
  end
  
  describe "listing launch configurations" do
    
    before(:all) do
      @launch_configuration = "rspec-test-configuration"
      @image = compute.register_image('image', 'image', '/dev/sda1').body
      @image_id = @image['imageId']
      lc = as.configurations.create(:id => @launch_configuration, :image_id => @image_id, :instance_type => 't1.micro')
    end
    
    it "should list every launch configuration" do
      get '/api/v1/auto_scaling/configurations'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      attributes.first['id'].should == @launch_configuration
      attributes.first['image_id'].should == @image_id
      attributes.first['instance_type'].should == 't1.micro'
      attributes.first['security_groups'].should == []
    end

  end
end

