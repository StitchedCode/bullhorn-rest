require 'spec_helper'
require 'bullhorn/rest'


describe Bullhorn::Rest::Entities::Candidate, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "pagination" do

    it "should return next page if there is one with special pagesize" do
      res = client.search_candidates(fields: 'id,name,fileAttachments(id)', query: "dateAdded:[20150101 TO 20160516] AND NOT status:Archive", sort: '-id', count: 200, pageSize: 200)

      expect(res.has_next_page?).to be true
      expect(res.start).to eq(0)
      expect(res.record_count).to eq(200)
    end

    it "should move to next page if there is one with special pagesize" do
      res = client.search_candidates(fields: 'id,name,fileAttachments(id)', query: "dateAdded:[20160301 TO 20160516] AND NOT status:Archive", sort: '-id', count: 200, pageSize: 200)

      expect(res.has_next_page?).to be true

      page_2 = res.next_page
      expect(page_2.has_next_page?).to be true
      expect(page_2.start).to eq(201)
      expect(page_2.record_count).to eq(200)

      page_3 = res.next_page
      expect(page_3.has_next_page?).to be true
      expect(page_3.start).to eq(401)
      expect(page_3.record_count).to eq(200)
    end

    it "should move through all pages using next_page with special pagesize" do
      entity = client.search_candidates(fields: 'id,name,fileAttachments(id)', query: "dateAdded:[20160301 TO 20160516] AND NOT status:Archive", sort: '-id', count: 200, pageSize: 200)

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

        puts "Fetched #{next_page.start} to #{next_page.start + next_page.record_count} of #candidates"
      end
      results
    end


  end

end
