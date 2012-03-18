require 'rack/test'

require_relative '../app'

include Rack::Test::Methods

def app
  Sinatra::Application
end
