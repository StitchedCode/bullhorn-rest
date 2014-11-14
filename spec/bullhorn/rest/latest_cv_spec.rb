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
      expect(lastFile.name).to eq("Matt Wright.pdf")

    end

    it "should return the latest CV" do 
      latest_cv = client.get_latest_cv(11853)

      decoded_data = Base64.decode64(latest_cv.fileContent)          
      expect(latest_cv.name).to eq("Matt Wright.pdf")
      expect(latest_cv.contentType).to eq("application/pdf")
            
    end

    it "should return a CV by ID file" do 
      res = client.get_cv(11853, 73782)
      puts res.contentType
      puts res.name
      puts "============================="
      #puts res.File.fileContent

      decoded_data = Base64.decode64(res.fileContent)          
      expect(res.name).to eq("Matt Wright.doc")
    end
 
    it "should return resumes" do
      res = client.get_latest_cv(35598)
      expect(res.name).to eq("Resume_Andy_Huang_201406.doc")

    end 

    it "should deal with no files elegantly" do
      res = client.get_latest_cv(36026)
      expect(res).to be_nil 
    end 
  
  end
  
end
