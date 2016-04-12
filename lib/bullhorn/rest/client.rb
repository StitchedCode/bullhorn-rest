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


  attr_reader :conn, :logger

  # Initializes a new Bullhorn REST Client
  def initialize(options = {})

    @conn = Faraday.new do |f|
      f.use Middleware, self
      f.response :logger
      f.request :multipart
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end
    @logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
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

  # So here we are again retying because of some failure on the BH api side. <Sigh>. Drink another Whiskey....such is the way with CV parsing. Such is the way.
  # http://supportforums.bullhorn.com/viewtopic.php?f=32&t=11921&st=0&sk=t&sd=a&start=15
  def convert_resume_to_html(file_content, format, content_type)
    path = "resume/convertToHtml?format=#{format}"
    attributes, result = {}
    retries = 1

    Timeout.timeout(30) {
      loop do
        file = make_temp_file(file_content)
        attributes['file'] = Faraday::UploadIO.new(file, content_type)
        res = conn.post path, attributes
        file.unlink
        result = Hashie::Mash.new JSON.parse(res.body)
        break if res.status == 200
        logger.warn "Status:#{res.status}. Retrying (convert_resume_to_html) for #{attributes['file'].original_filename}.....retry number:#{retries}"
        logger.warn "Body: #{res.body}"
        retries+=1
      end
    }
    result
  end

  def candidate_files(candidate_id, attributes={})
    path = "entityFiles/Candidate/#{candidate_id}"
    res = conn.get path, attributes
    Hashie::Mash.new JSON.parse(res.body)
  end

  def cv(candidate_id, file_id, attributes={})
    path = "file/Candidate/#{candidate_id}/#{file_id}"
    res = conn.get path, attributes
    obj = Hashie::Mash.new JSON.parse(res.body)
    obj.File
  end

  def parse_to_candidate_as_file(format, pop, attributes)
    path = "resume/parseToCandidate?format=#{format}&populateDescription=#{pop}"
    attributes['file'] = Faraday::UploadIO.new(attributes['file'], attributes['ct'])
    res = conn.post path, attributes
    Hashie::Mash.new JSON.parse(res.body)
  end

  def all_cvs(candidate_id, attributes={})
    cvs = []
    files = candidate_files(candidate_id, attributes)
    files.EntityFiles.each do |file|
      file.except!(:description)
      cvs.push(file.merge({cv_file: cv(candidate_id, file.id)}))
    end
    cvs
  end

  def latest_cv(candidate_id, attributes={})
    filter_cvs = attributes.delete(:accepted_cv_formats) { false }
    res = candidate_files(candidate_id, attributes)
    if filter_cvs
      cvs = res.EntityFiles.select { |file| filter_cvs.include?(file.type) }
    else
      cvs = res.EntityFiles
    end
    cvs.last.nil? ? nil : cvs.last.merge({cv_file: cv(candidate_id, cvs.last.id)})
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

  def events(subscription_id)
     path = "event/subscription/#{subscription_id}?maxEvents=500"
     res = conn.get path
     res.body.blank? ? "" : Hashie::Mash.new(JSON.parse(res.body))
  end

  def events_by_requestId(subscription_id, request_id)
     path = "event/subscription/#{subscription_id}?requestId=#{request_id}"
     res = conn.get path
     res.body.blank? ? "No Results for subscription:#{subscription_id}, request:#{request_id}" : Hashie::Mash.new(JSON.parse(res.body))
  end

  def meta_data(entity, attributes)
     path = "meta/#{entity}"
     res = conn.get path, attributes
     res.body.blank? ? "" : Hashie::Mash.new(JSON.parse(res.body))
  end

  private

  def make_temp_file(content)
    temp_file = Tempfile.new(SecureRandom.uuid)
    File.open(temp_file, 'wb') { |file| file.write(content) }
    temp_file
  end

end
end
end
