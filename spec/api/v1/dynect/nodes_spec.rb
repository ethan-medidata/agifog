require 'spec_helper'


describe "/api/v1/dynect/zones/zone/nodes", :vcr, :type => :api do
  describe "listing and showing" do
    before(:all) do
      VCR.use_cassette('dynect_prepopulate_records') do
        @a_fqdn = "rspec-agifog-a.imedidata.net"
        @a_address = "192.168.1.1"
        @cname_fqdn = "rspec-agifog-cname.imedidata.net"
        @cname_url = "www.google.com"
        @ttl = 600
        dynect.a.fqdn(@a_fqdn).ttl(@ttl).address(@a_address).save
        dynect.cname.fqdn(@cname_fqdn).cname(@cname_url).save
        dynect.publish
      end
    end
    
    it "shows an array of nodes" do
      get "/api/v1/dynect/zones/#{zone}/nodes/"
      last_response.should be_ok
      nodes = JSON.parse(last_response.body)
      nodes.should_not be_empty
      node = nodes.find { |n| n == @cname_fqdn }
      node.should_not be_empty
    end
    
    it "shows a specific node" do
      get "/api/v1/dynect/zones/#{zone}/nodes/#{@a_fqdn}"
      last_response.should be_ok
      node = JSON.parse(last_response.body)
      record = node.find { |n| n['fqdn'] == @a_fqdn }
      record.should_not be_empty
      record["zone"].should == zone
      record["ttl"].should == @ttl
      record["record_type"].should == 'A'
      record["rdata"]["address"].should == @a_address
    end
  end
  
  describe "creating and deleting" do
    before(:all) do
      @new_node_fqdn = "rspec-create.imedidata.net"
      @new_cname_url = "www.yahoo.com"
    end
    
    it "creates a new node with a cname record" do
      post "/api/v1/dynect/zones/#{zone}/nodes/", {:node => {
        :fqdn => @new_node_fqdn,
        :record_type => "CNAME",
        :rdata => {:cname => @new_cname_url },
        :zone => zone,
        :ttl => 300 }
        }.to_json
      last_response.status == 201
      response = JSON.parse(last_response.body)
      response.should == "OK"
    end
    
    it "deletes a node" do
      delete "/api/v1/dynect/zones/#{zone}/nodes/#{@new_node_fqdn}"
      last_response.should be_ok
      response = JSON.parse(last_response.body)
      response.should == ["#{@new_node_fqdn} was deleted successfully"]
    end
  end
  
end