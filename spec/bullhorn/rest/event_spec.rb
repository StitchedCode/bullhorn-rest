require 'spec_helper'
require 'bullhorn/rest'


describe Bullhorn::Rest::Entities::Event, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "creation" do 
    it "should return subscription and created on" do 
      subs = "testSubs123"
      #res = client.create_event(subs, "Candidate") 
      #expect(res["subscriptionId"]).to eq(subs)               
    end  
  end

  describe "subscription" do 
    it "should return recent results" do 
      subs = "testSubs123"
      res = client.get_subscription(subs) 
      puts res
    end  
  end

  describe "subscription" do 
    it "should get last request id" do 
      subs = "testSubs123"
      #res = client.get_subscription_last_request(subs,1) 
      puts res
    end  
  end

end
