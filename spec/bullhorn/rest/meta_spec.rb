require 'spec_helper'
require 'bullhorn/rest'


describe Bullhorn::Rest::Client, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "meta_get" do

    it "should return metadata for Job Order" do 
      res = client.get_meta_data("JobOrder", {:fields => "*"})       
      expect(res.fields.find {|n| n.name == "status" }.options.first.value).to eq("Accepting Candidates")       
    end  

  end

end
