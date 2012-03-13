require 'spec_helper'

describe "/api/v1/rds/parameter_groups", :type => :api do
  
  it "should return two parameter_groups by default" do
    get '/api/v1/rds/parameter_groups'
    last_response.should be_ok
    parameter_groups = JSON.parse(last_response.body)
    parameter_groups.should have(2).items
  end
  
  describe "listing parameter_groups" do
    
    before(:all) do
      @group_name_one = "rspec-list-one"
      pg = rds.parameter_groups.create(:id => @group_name_one, :family => 'mysql5.5', :description => 'self-generated')
      pg = rds.parameter_groups.create(:id => 'rspec-list-second', :family => 'mysql5.1', :description => 'self-generated')
    end
    
    it "should list every parameter_group" do
      get '/api/v1/rds/parameter_groups'
      last_response.should be_ok
      attributes = JSON.parse(last_response.body)
      item = attributes.find { |lc| lc['id'] == @group_name_one }
      item.should_not be_empty
      item["id"].should == @group_name_one
      item['family'].should == 'mysql5.5'
      item['description'].should == 'self-generated'
    end
    
    it "should show a parameter_group" do
      get "/api/v1/rds/parameter_groups/#{@group_name_one}"
      last_response.should be_ok
      item = JSON.parse(last_response.body)
      item.should_not be_empty
      item["id"].should == @group_name_one
      item['family'].should == 'mysql5.5'
      item['description'].should == 'self-generated'
    end
    
    it "should return 404 when a parameter_group doesn't exist" do
      get "/api/v1/rds/parameter_groups/dontexist.json"
      last_response.should_not be_ok
      last_response.status.should == 404
      attributes = JSON.parse(last_response.body)
      attributes["errors"].should == ["dontexist parameter group not found"]
    end
  end #describe listing
  
#  describe "create parameter_groups" do
#    before(:all) do
#      @other_launch_parameter_group = "rspec-create-parameter_group"
#    end
#    
#    it "should create a parameter_group" do
#      post "/api/v1/rds/parameter_groups", {:parameter_group => { 
#          :id => @other_launch_parameter_group,
#          :family => 'mysql5.5',
#          :description => 'self-generated'}
#        }.to_json
#      last_response.status == 201
#      attributes = JSON.parse(last_response.body)
#      attributes['id'].should == @other_launch_parameter_group
#      attributes['family'].should == 'mysql5.5'
#      attributes['description'].should == 'self-generated'
#      
#      # verify that it was created
#      get "/api/v1/rds/parameter_groups/#{@other_launch_parameter_group}"
#      last_response.should be_ok
#      attribute = JSON.parse(last_response.body)
#      attribute['id'].should == @other_launch_parameter_group
#      attributes['family'].should == 'mysql5.5'
#      attributes['description'].should == 'self-generated'
#    end
#    
#    
#    it "should fail if all the required params aren't passed" do
#      post "/api/v1/rds/parameter_groups", {:parameter_group => { 
#          :id => @other_launch_parameter_group,
#          :description => 'self-generated'}
#        }.to_json
#      last_response.status == 400
#      attributes=JSON.parse(last_response.body)
#      attributes["errors"].should == ["image_id is required for this operation"]
#    end
#  end #describe create
#  
#  describe "should delete parameter_groups" do
#    before(:all) do
#      @launch_parameter_group_delete = "rspec-delete-parameter_group"
#      pg = rds.parameter_groups.create(:id => @launch_parameter_group_delete, :family => 'mysql5.5', :description => 'self-generated')
#    end
#    
#    it "delete an existing parameter_group" do
#      delete "/api/v1/rds/parameter_groups/#{@launch_parameter_group_delete}"
#      last_response.should be_ok
#      # verify that it was deleted
#      get "/api/v1/rds/parameter_groups/#{@launch_parameter_group_delete}"
#      last_response.should_not be_ok
#      last_response.status.should == 404
#    end
#  end
end