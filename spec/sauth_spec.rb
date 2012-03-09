require '../sauth'
require 'rack/test'
require 'test/unit'

set :environment, :test

describe 'The App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

describe "Authenticatin Service" do

#########################
#User registration
#########################
  describe "User registration" do

#########################
#get /sauth/register
#########################
    describe "get /sauth/register" do
      it "should get /sauth/register" do
        get '/sauth/register'
        last_response.should be_ok
         end

      it "should return a form to post registration info to /sauth/register" do
        get '/sauth/register'
        last_response.body.should match %r{<form action="/sauth/register" method="post".*}
         end
    end
#########################
#post /sauth/register
#########################
    describe "post /sauth/register" do
      before do
        @params = { "user" => {"login" => "jriby", "passwd" => "pass" }}
      end
      it "should create a new user" do
        User.stub(:create)
        User.should_receive(:create).with(@params['user'])
        post '/sauth/register', @params
      end

      it "should redirect to /sauth/session/new" do
        User.stub(:create){true}
        post '/sauth/register', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/sauth/session/new'
      end

      context "Registration is not OK" do

         it "should render the registration form" do
           User.stub(:create)
           User.should_receive(:create).with(@params['user']).and_return(false)
           post '/sauth/register', @params
           last_response.body.should match %r{<form action="/sauth/register" method="post".*}
         end
      end

    end
#########################
#get /sauth/session/new
#########################
    describe "get /sauth/session/new" do
      it "should get /session/new" do
        get '/sauth/session/new'
        last_response.should be_ok
         end

      it "should return a form to post registration info to /sauth/register" do
        get '/sauth/session/new'
        last_response.body.should match %r{<form action="/sauth/session/new" method="post".*}
         end
    end



  end 
end

end

