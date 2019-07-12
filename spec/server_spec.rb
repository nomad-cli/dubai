# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require_relative '../lib/dubai/server'

include Rack::Test::Methods

describe Dubai::Server do
  let(:app) { Dubai::Server }

  describe 'GET /pass.pkpass' do
    it 'returns pkpass' do
      Dubai::Server.set(:directory, 'directory')
      pkpass = double(string: 'your.pkpass')
      pass = double(pkpass: pkpass)
      allow(Dubai::Passbook::Pass).to receive(:new).with('directory').and_return(pass)

      get '/pass.pkpass'

      expect(last_response.body).to eq('your.pkpass')
    end
  end
end
