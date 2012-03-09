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
       @params_create = { 'user' => {"login" => "login", "passwd" => "pass" }}
        @params = { 'login' => "login", "passwd" => "pass" }
      
        @u = User.new
        @u.login = "login"
        @u.passwd = "pass"
      end

      it "should use create" do

        User.stub(:create)
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
        post '/sauth/register', @params
      end

      it "should create user with login set in browser" do

        User.stub(:create)
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
         
        @u.login.should == @params['login']
        post '/sauth/register', @params
      end

      it "should create user with passwd encypt set in browser" do

        User.stub(:create)
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
        @u.passwd.should == User.encrypt_password(@params['passwd'])
        post '/sauth/register', @params
      end


      it "should redirect to /sauth/session/new" do
        User.stub(:create)
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
        post '/sauth/register', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/sauth/session/new'
      end

      context "Registration is not OK" do

        it "should render the registration form if the login is not set" do
           
           @u.login = ""
           User.stub(:create)
           User.should_receive(:create).with(@params_create['user']).and_return(@u)
           post '/sauth/register', @params
           last_response.body.should match %r{<form action="/sauth/register" method="post".*}
         end

         it "should render the registration form if the pass is not set" do
           
           @u.passwd = ""
           User.stub(:create)
           User.should_receive(:create).with(@params_create['user']).and_return(@u)
           post '/sauth/register', @params
           last_response.body.should match %r{<form action="/sauth/register" method="post".*}
         end


        it "should render the registration form if the login and the pass are not set" do
           
           @u.login = ""
           @u.passwd = ""
           User.stub(:create)
           User.should_receive(:create).with(@params_create['user']).and_return(@u)
           post '/sauth/register', @params
           last_response.body.should match %r{<form action="/sauth/register" method="post".*}
         end

        it "should render the registration form if the login is already taken" do
           
           ut = User.new
           ut.login = "taken"
           ut.passwd = "pass"
           ut.save

           @u.login = "taken"
           @u.passwd = "taken"
           User.stub(:create)
           User.should_receive(:create).with(@params_create['user']).and_return(@u)
           post '/sauth/register', @params
           last_response.body.should match %r{<form action="/sauth/register" method="post".*}

           ut.destroy
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

