require 'spec_helper'
require 'bullhorn/rest/entities/resume'
require 'bullhorn/rest'


describe Bullhorn::Rest::Client, :vcr do

  let(:client) { Bullhorn::Rest::Client.new(client_id: test_bh_client_id, client_secret: test_bh_client_secret, username: test_bh_username, password: test_bh_password) }

  describe "cv files" do 


    it "should return the latest a candidates list of files" do 
      res = client.get_candidate_files(11853)

      cvs = res.EntityFiles.select { |file| file.type == 'CV' }

      lastFile =  cvs.last      
      puts lastFile.fileUrl
      puts lastFile.id
      puts Time.at(lastFile.dateAdded / 1000.0)
      puts lastFile.name
      puts lastFile.type
      puts "============================="
      #puts lastFile       

     # puts res.EntityFiles
      expect(lastFile.name).to eq("Matt Wright.doc")

    end

    it "should return the latest CV" do 
      latest_cv = client.get_latest_cv(11853)

      decoded_data = Base64.decode64(latest_cv.File.fileContent)          
      expect(latest_cv.File.name).to eq("Matt Wright.doc")
      expect(latest_cv.File.contentType).to eq("application/msword")
            
    end

    it "should return a CV by ID file" do 
      res = client.get_cv(11853, 73782)
      puts res.File.contentType
      puts res.File.name
      puts "============================="
      #puts res.File.fileContent

      decoded_data = Base64.decode64(res.File.fileContent)          
      expect(res.File.name).to eq("Matt Wright.doc")
    end
 

  end
  

end