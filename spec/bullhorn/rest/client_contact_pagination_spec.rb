require 'spec_helper'
require 'bullhorn/rest/entities/resume'
require 'bullhorn/rest'


describe Bullhorn::Rest::Entities::ClientContact, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "pagination" do 


    it "should move to next page if there is one" do 
      res = client.client_contacts 
      expect(res.has_next_page).to be(true)            

      page_2 = res.next_page
      expect(page_2.start).to eq(501)      
      expect(page_2.record_count).to eq(500)
   
    end

    it "should through all pages using next_page" do 
      entity = client.client_contacts 
      results = []           

      #If there is no next page to go to just append results
      results.concat(entity.data) 

      while entity.has_next_page?         
        next_page = entity.next_page
        results.concat(next_page.data)
        entity.has_next_page = next_page.has_next_page
        entity.start = next_page.start     
        
        unless entity.has_next_page?
          puts next_page.start
        end 

        puts "Fetched #{next_page.start} to #{next_page.start + next_page.record_count} of #Contacts"  
      end 
      results    
    end

  end
  

end
