require 'spec_helper'
require 'bullhorn/rest/entities/resume'
require 'bullhorn/rest'



describe Bullhorn::Rest::Entities::Candidate, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "pagination" do

    it "should return correct totals when initialized" do
      res = client.candidates

      #expect(res.total).to eq(13292)
      expect(res.start).to eq(0)
      expect(res.record_count).to eq(500)
    end

    it "should return next page if there is one" do
      res = client.candidates

      expect(res.has_next_page?).to be true
    end


  end


end
