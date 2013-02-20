require 'sinatra/base'

module Dubai
  class Server < Sinatra::Base
    get '/pass.pkpass' do
      content_type 'application/vnd.apple.pkpass'
      attachment "pass.pkpass"

      Passbook::Pass.new(settings.directory).pkpass.string
    end
  end
end
