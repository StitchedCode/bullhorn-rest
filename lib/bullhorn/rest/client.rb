require 'faraday'
require 'bullhorn/rest/authentication'
require 'bullhorn/rest/entities/base'

Dir[File.dirname(__FILE__) + '/entities/*.rb'].each {|file| require file }

module Bullhorn
module Rest

class Client

  include Bullhorn::Rest::Authentication
  include Bullhorn::Rest::Entities::Appointment
  include Bullhorn::Rest::Entities::AppointmentAttendee
  include Bullhorn::Rest::Entities::BusinessSector
  include Bullhorn::Rest::Entities::Candidate
  include Bullhorn::Rest::Entities::CandidateCertification
  include Bullhorn::Rest::Entities::CandidateEducation
  include Bullhorn::Rest::Entities::CandidateReference
  include Bullhorn::Rest::Entities::CandidateWorkHistory
  include Bullhorn::Rest::Entities::Category
  include Bullhorn::Rest::Entities::ClientContact
  include Bullhorn::Rest::Entities::ClientCorporation
  include Bullhorn::Rest::Entities::CorporateUser
  include Bullhorn::Rest::Entities::CorporationDepartment
  include Bullhorn::Rest::Entities::Country
  include Bullhorn::Rest::Entities::CustomAction
  include Bullhorn::Rest::Entities::JobOrder
  include Bullhorn::Rest::Entities::JobSubmission
  include Bullhorn::Rest::Entities::JobSubmissionHistory
  include Bullhorn::Rest::Entities::Note
  include Bullhorn::Rest::Entities::NoteEntity
  include Bullhorn::Rest::Entities::Placement
  include Bullhorn::Rest::Entities::PlacementChangeRequest
  include Bullhorn::Rest::Entities::PlacementCommission
  include Bullhorn::Rest::Entities::Resume
  include Bullhorn::Rest::Entities::Sendout
  include Bullhorn::Rest::Entities::Skill
  include Bullhorn::Rest::Entities::Specialty
  include Bullhorn::Rest::Entities::State
  include Bullhorn::Rest::Entities::Task
  include Bullhorn::Rest::Entities::Tearsheet
  include Bullhorn::Rest::Entities::TearsheetRecipient
  include Bullhorn::Rest::Entities::TimeUnit


  attr_reader :conn

  # Initializes a new Bullhorn REST Client
  def initialize(options = {})

    @conn = Faraday.new do |f|
      f.use Middleware, self
      f.response :logger 
      f.adapter Faraday.default_adapter
    end

    [:username, :password, :client_id, :client_secret, :auth_code, :access_token, :refresh_token, :ttl, :rest_url, :rest_token, :auth_host, :rest_host].each do |opt|
      self.send "#{opt}=", options[opt] if options[opt]
    end

  end

  #There is probably a case for puting all this in a helper method at some point
  def parse_to_candidate(resume_text)
      path = "resume/parseToCandidateViaJson?format=text"
      encodedResume = {"resume" => resume_text}.to_json   
      res = conn.post path, encodedResume
      Hashie::Mash.new JSON.parse(res.body)
  end 

  def get_candidate_files(candidate_id, attributes={})
    path = "entityFiles/Candidate/#{candidate_id}"
    res = conn.get path, attributes
    Hashie::Mash.new JSON.parse(res.body)
  end

  def get_cv(candidate_id, file_id, attributes={})
    path = "file/Candidate/#{candidate_id}/#{file_id}"
    res = conn.get path, attributes
    obj = Hashie::Mash.new JSON.parse(res.body)
    obj.File
  end 

  def get_latest_cv(candidate_id, attributes={})
    res = get_candidate_files(candidate_id)
    accepted_cv_formats = ["CV", "Resume", "Formatted CV"]    
    cvs = res.EntityFiles.select { |file| accepted_cv_formats.include?(file.type) }    
    cvs.last.nil? ? nil : get_cv(candidate_id, cvs.last.id)     
  end 

  def upload_cv(candidate_id, attributes={})
    puts attributes.to_json
    path = "file/Candidate/#{candidate_id}"
    res = conn.put path, attributes.to_json
    Hashie::Mash.new JSON.parse(res.body)
  end 

  def create_event(subscription_id, entity)
     path = "event/subscription/#{subscription_id}?type=entity&names=#{entity}&eventTypes=INSERTED,UPDATED,DELETED"  
     res = conn.put path
     Hashie::Mash.new JSON.parse(res.body)
  end 

  def delete_event(subscription_id)
     path = "event/subscription/#{subscription_id}"  
     res = conn.delete path
     Hashie::Mash.new JSON.parse(res.body)
  end   

  def get_events(subscription_id)
     path = "event/subscription/#{subscription_id}?maxEvents=500"  
     res = conn.get path
     res.body.blank? ? "" : Hashie::Mash.new(JSON.parse(res.body))
  end 

  def get_events_by_requestId(subscription_id, request_id)
     path = "event/subscription/#{subscription_id}?requestId=#{request_id}"  
     res = conn.get path
     res.body.blank? ? "No Results for subscription:#{subscription_id}, request:#{request_id}" : Hashie::Mash.new(JSON.parse(res.body))
  end 

  def get_meta_data(entity, attributes)
     path = "meta/#{entity}"  
     res = conn.get path, attributes
     res.body.blank? ? "" : Hashie::Mash.new(JSON.parse(res.body))
  end 

end
end
end
