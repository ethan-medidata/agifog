require 'spec_helper'

describe "/api/v1/iam/users", :type => :api do
  it "returns an empty array when there are no users" do
    get '/api/v1/iam/users.json'
    last_response.should be_ok
    last_response.body.should be_json_eql('[]')
  end
  
  describe "Reading requests for iam users" do
  
    before(:all) do
      @user = iam.users.create(:id => 'rspec-user')
      @another_user = iam.users.create(:id => 'another-rspec-user')
      @user_json = %({  "id":      "#{@user.id}",
                        "path":    "#{@user.path}",
                        "arn":     "#{@user.arn}",
                        "user_id": "#{@user.user_id}"  
                    })
      
    end
    after(:all) do
      @user.destroy
    end
    
    describe "GET /api/v1/iam/users" do
      it "returns two users" do
        get '/api/v1/iam/users.json'
        last_response.should be_ok
        last_response.body.should have_json_size(2)
      end
        
    
      it "verifies that one of the users has the proper values" do
        get '/api/v1/iam/users.json'
        last_response.should be_ok
        last_response.body.should include_json(@user_json)
      end
    end
    
    describe "GET /api/v1/iam/users/:id" do
      it "returns an existing user" do
        get "/api/v1/iam/users/#{@user.id}.json"
        last_response.should be_ok
        last_response.body.should be_json_eql(@user_json)
      end
      
      it "returns 404 for a non-existing user" do
        get "/api/v1/iam/users/non-existing.json"
        last_response.status.should == 404
        last_response.body.should be_json_eql('{ "errors": ["non-existing iam user not found"] }')
      end
    end
  end

  describe "Writing requests for iam users" do
    describe "POST /api/v1/iam/users" do
      it "creates a user with a valid json blob" do
        post "/api/v1/iam/users.json", '{ "user": {"id": "iam-user-test" } }'
        last_response.status.should == 200
        puts last_response.body.should have_json_path("id")
      end
      
      it "returns 409 when the user already exists" do
        post "/api/v1/iam/users.json", {:user => {:id => "iam-user-test" } }.to_json
        last_response.status.should == 409
        last_response.body.should be_json_eql('{ "errors": ["User with name iam-user-test already exists."] }')
        
      end
      
      it "returns 406 when the json blob is invalid" do
        post "/api/v1/iam/users.json", 'invalid-json-blob'
        last_response.status.should == 406
        last_response.body.should be_json_eql('{ "errors": ["The request failed because its format is not valid; it could not be parsed"] }')  
      end
      
    end
    
    describe "DELETE /api/v1/iam/users/:id" do
      it "returns 200 when a user is deleted properly" do
        delete "/api/v1/iam/users/iam-user-test.json"
        last_response.status.should == 200
        last_response.body.should be_json_eql('["iam-user-test was deleted successfully"]')
      end
      
      it "returns 404 when it tries to delete a non existing user" do
        delete "/api/v1/iam/users/non-existing.json"
        last_response.status.should == 404 
        last_response.body.should be_json_eql('{ "errors": ["non-existing iam user not found"] }')  
      end
    
    end
  end
end