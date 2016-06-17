require 'spec_helper'
require 'bullhorn/rest/entities/resume'
require 'bullhorn/rest'
require 'tempfile'


describe Bullhorn::Rest::Client, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

    describe "Update existing candidates " do
      it "should update primary skills " do
        payload = {ids: [11853], primarySkills: [375606, 11481]}
        res = client.mass_update_candidate(payload.to_json)
        expect(res.count).to eq(1)
      end
    end

    describe "Adding new candidates " do

    it "should convert to html" do
      #json  = File.read("spec/fixtures/example_resume_upload.json")
      #res = client.create_candidate(json)
      #base64_content = Base64.encode64(file)
      5.times do
        file  = File.new("spec/fixtures/mattwright.pdf", "rb")
        res = client.convert_resume_to_html(file.read, "pdf", "application/pdf")
        puts res.html
      end
    end

    it "should insert new candiate" do

      json  = File.read("spec/fixtures/example_resume_upload.json")
      #res = client.create_candidate(json)
      #expect(res.changedEntityId).to_not be_nil
    end

    it "should allow primary skills association" do

      json  = File.read("spec/fixtures/example_resume_upload.json")
      #res = client.create_candidate(json)
      #res = client.associate_candidate(res.changedEntityId, "primarySkills", [58,128909])

    end

    it "should allow CV Upload" do

#      file_content  = File.read("spec/fixtures/mattwright.pdf")
 #     json  = File.read("spec/fixtures/example_resume_upload.json")
      #res = client.create_candidate(json)
  #    base64_content = Base64.encode64(file_content)
   #   client.upload_cv(37383, {:externalID => "CV", :fileContent => base64_content, :fileType => "SAMPLE", name: "mattwright.pdf" })

      #res = client.associate_candidate(res.changedEntityId, "primarySkills", [58,128909])
    end

  end

end
