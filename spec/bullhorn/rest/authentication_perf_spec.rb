require 'spec_helper'

describe Bullhorn::Rest::Authentication, :vcr do

  let(:default_options) {{client_id: test_bh_client_id, client_secret: test_bh_client_secret}}
  let(:options) {{}}
  let(:client) { Bullhorn::Rest::Client.new(default_options.merge(options)) }


  context 'hit it hard and often' do

    let(:options) {{username: test_bh_username, password: test_bh_password}}

    it 'authenticates often' do
      (0..10).each do |i|
        puts "Setting up connection: #{i}"
        client_bh = Bullhorn::Rest::Client.new(default_options.merge(options))
        client_bh.authenticate
      end
    end

  end
end
