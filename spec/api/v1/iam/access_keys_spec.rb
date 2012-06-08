require 'spec_helper'

describe "/api/v1/iam/users/:user_id/access_keys", :type => :api do
  before(:all) do
    @user = iam.users.create(:id => 'fake-user-ak')    
  end
  
  after(:all) do
    @user.destroy  
  end
  
  it "returns an empty array when there are no access_keys" do
    get "/api/v1/iam/users/fake-user-ak/access_keys.json"
    last_response.should be_ok
    last_response.body.should be_json_eql('[]')
  end
  
  describe "Reading requests for iam users" do
  
    before(:all) do
      @access_key = @user.access_keys.create
      @access_key_json = %( 
                           {  
                              "id":"#{@access_key.id}",
                              "username":"fake-user-ak",
                              "status": "Active"
                            }
                          )
                    
      @another_access_key = @user.access_keys.create
    end  
    
    describe "GET /api/v1/iam/users/:user_id/access_keys" do
      it "returns two access_keys" do
        get '/api/v1/iam/users/fake-user-ak/access_keys.json'
        last_response.should be_ok
        last_response.body.should have_json_size(2)
      end
        
    
      it "verifies that one of the user's access_key has the proper values" do
        get '/api/v1/iam/users/fake-user-ak/access_keys.json'
        last_response.should be_ok
        last_response.body.should include_json(@access_key_json)
      end
    end
    
    describe "GET /api/v1/iam/users/:id" do
      it "returns an existing user's access_key" do
        get "/api/v1/iam/users/fake-user-ak/access_keys/#{@access_key.id}.json"
        last_response.should be_ok
        last_response.body.should be_json_eql(@access_key_json)
      end
      
      it "returns 404 for a non-existing user's access_key" do
        get "/api/v1/iam/users/fake-user-ak/access_keys/non-existing.json"
        last_response.status.should == 404
        last_response.body.should be_json_eql('{ "errors": ["non-existing access key not found"] }')
      end
    end
  end 

  describe "Writing requests for iam user's access_key" do
    
    describe "POST /api/v1/iam/users/fake-user-ak/access_keys" do
      
      it "creates a user with a valid json blob" do
        post "/api/v1/iam/users/fake-user-ak/access_keys.json", ''
        last_response.status.should == 200
        puts last_response.body.should have_json_path("id")
      end
      
      # Pending: mocking doesn't have this restriction
      #it "returns 422 when there are more than two access_keys already created" do
      #  post "/api/v1/iam/users/fake-user-ak/access_keys.json", ''
      #  last_response.status.should == 422
      #  last_response.body.should be_json_eql('{ "errors": ["Cannot exceed quota for AccessKeysPerUser: 2"] }')
      #end
      
      
    end
    
    describe "DELETE /api/v1/iam/users/:id" do
      before(:all) do 
        @access_key = @user.access_keys.create
      end
      
      it "returns 200 when a user's access_key is deleted properly" do
        delete "/api/v1/iam/users/fake-user-ak/access_keys/#{@access_key.id}.json"
        last_response.status.should == 200
        last_response.body.should be_json_eql(%(["#{@access_key.id} was deleted successfully"]))
      end
      
      it "returns 404 when it tries to delete a non existing user's access_key" do
        delete "/api/v1/iam/users/fake-user-ak/access_keys/non-existing.json"
        last_response.status.should == 404 
        last_response.body.should be_json_eql('{ "errors": ["non-existing access key not found"] }')  
      end
    
    end
  end
end