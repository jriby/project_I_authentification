require '../sauth'  # <-- your sinatra app
require 'rack/test'

set :environment, :test

describe 'The sauth App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "A user want to register" do

    it "should be ok if a user go to /sauth/register" do
      get '/sauth/register'
      last_response.should be_ok
    end
    
    it "should return status 200 if a user go to /sauth/register" do
      last_response.status.should == 200
    end

 
end

