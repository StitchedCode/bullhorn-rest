require 'spec_helper'
require 'bullhorn/rest'


describe Bullhorn::Rest::Entities::Event, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }


  describe "creation" do

    it "should return subscription and created on" do 
      subs = "testSubsNew"
      res = client.create_event(subs, "Candidate")       
      expect(res["subscriptionId"]).to eq(subs)       
    end  

    it "should delete subscription" do 
      subs = "testSubsNew"
      res = client.delete_event(subs) 
  
      expect(res["result"]).to be(true)               
    end  
  end


  describe "subscription" do 
    
    it "should return recent results" do 
      subs = "testSubs12"
      #matt = client.candidate(37383)    
      #matt["data"]["nickName"]
      client.update_candidate(37383,{:nickName => "MrMacWright" }.to_json)
      res = client.get_events(subs) 
  
      expect(res["events"].count).to eq(1)
      update = res["events"].first
      expect(update["entityName"]).to eq("Candidate")
      expect(update["entityId"]).to eq(37383)
      expect(update["updatedProperties"]).to eq(["nickName"])              
    end  

    it "should get last request id" do 
      subs = "testSubs12"
      res = client.get_events_by_requestId(subs,7) 
      expect(res["events"].count).to eq(122) 
    end  
  end

end
