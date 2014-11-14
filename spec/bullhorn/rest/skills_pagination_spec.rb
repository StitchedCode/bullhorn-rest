require 'spec_helper'
require 'bullhorn/rest/entities/resume'
require 'bullhorn/rest'


describe Bullhorn::Rest::Entities::Skill, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "pagination" do 


    it "should return next page if there is one" do 
      res = client.job_orders
    
    	#For entities without 1->M relationships we can get it batchs of 500. In our test case we only have 200ish
      # client.search_job_orders(query: "dateAdded:[20140701 TO 20140801]", sort: "-dateAdded")
      #     vacancies =  client.search_job_orders(query: "dateAdded:[#{start_date} TO #{end_date}]", fields: "*,submissions(*)" , sort: "-dateAdded")

      person = client.client_contact(37318)
      expect(res.has_next_page?).to be false
    end

    it "should return correct totals when initialized" do 
      res = client.candidates

      expect(res.start).to eq(0)
      expect(res.record_count).to eq(500)
    end
  

    it "should return ordered list by default" do 
      res = client.skills
      skill = client.skills.data.first
      expect(skill.name).to eq(".NET")
    end
  

  end
  

end
