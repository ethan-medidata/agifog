require 'spec_helper'

describe "/api/v1/iam/users/:user_id/policies", :type => :api do
  before(:all) do
    @user = iam.users.create(:id => 'fake-user-pol')    
  end
  
  after(:all) do
    @user.destroy   
  end
  
  it "returns an empty array when there are no policies" do
    get "/api/v1/iam/users/#{@user.id}/policies.json"
    last_response.should be_ok
    last_response.body.should be_json_eql('[]')
  end
  
  context "giving two iam user's policies" do 
    before(:all) do
      @document_policy = '{"Statement":[{"Effect":"Allow","Action":"*","Resource":"*"}]}}'       
      @policy = @user.policies.create(id: 'fake-policy', document: @document_policy)

      @policy_json = '{
        "username": "fake-user-pol",
        "id": "fake-policy",
        "document": "{\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}}"
      }'
                      
      @user.policies.create(id: 'another-fake-policy', document: %({"Statement"=>[{"Action"=>["rds:*"], "Effect"=>"Deny", "Resource"=>"*"}]}) )
    end
    
    describe "GET /api/v1/iam/users/:id" do
      it "returns an existing user's policy" do
        get '/api/v1/iam/users/fake-user-pol/policies/fake-policy.json'
        last_response.should be_ok
        last_response.body.should be_json_eql(@policy_json)
      end
    
      it "returns 404 for a non-existing user's policy" do
        get "/api/v1/iam/users/fake-user-pol/policies/non-existing.json"
        last_response.status.should == 404
        last_response.body.should be_json_eql('{ "errors": ["non-existing policy not found"] }')
      end
    end
    
    describe "GET /api/v1/iam/users/:user_id/policies" do
      it "returns two policies" do
        get '/api/v1/iam/users/fake-user-pol/policies.json'
        last_response.should be_ok
        last_response.body.should have_json_size(2)
      end
        
      it "verifies that one of the user's policy has the proper values" do
        get '/api/v1/iam/users/fake-user-pol/policies.json'
        last_response.should be_ok
        JSON.pretty_generate(JSON.parse(last_response.body)).should include_json(@policy_json)
      end
    end
  end
    

  context "Writing requests for iam user's policy" do
    describe "POST /api/v1/iam/users/fake-user-pol/policies" do
      it "creates a user with a valid json blob" do
        post "/api/v1/iam/users/fake-user-pol/policies", '{ "policy": {"id": "policy-test", "document": {} } }'
        last_response.status.should == 200
        last_response.body.should have_json_path("id")
      end
      
      it "returns 406 when the json blob is invalid" do
        post "/api/v1/iam/users/fake-user-pol/policies.json", 'invalid-json-blob'
        last_response.status.should == 406
        last_response.body.should be_json_eql('{ "errors": ["The request failed because its format is not valid; it could not be parsed"] }')  
      end      
    end
    
    describe "DELETE /api/v1/iam/users/:user_id/policies/:id" do
      before(:all) do 
        @policy = @user.policies.create(id: 'policy-to-delete', document: {})
      end
      
      it "returns 200 when a user's policy is deleted properly" do
        delete "/api/v1/iam/users/fake-user-pol/policies/#{@policy.id}.json"
        last_response.status.should == 200
        last_response.body.should be_json_eql(%(["#{@policy.id} was deleted successfully"]))
      end
      
      it "returns 404 when it tries to delete a non existing user's policy" do
        delete "/api/v1/iam/users/fake-user-pol/policies/non-existing.json"
        last_response.status.should == 404 
        last_response.body.should be_json_eql('{ "errors": ["non-existing policy not found"] }')  
      end
    
    end
  end
end