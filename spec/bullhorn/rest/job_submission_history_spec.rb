require 'spec_helper'
require 'bullhorn/rest/entities/job_submission_history'
require 'bullhorn/rest'


describe Bullhorn::Rest::Entities::JobSubmissionHistory, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "job_submission_history" do 

    it "should get all job history" do 
  

      end
  end
  

end
