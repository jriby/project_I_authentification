require '../sauth'
require 'rack/test'
require 'test/unit'
require 'sinatra'

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
        last_request.path.should == '/'
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
end

#########################
#Connexion Service
#########################
describe "Connexion Service" do

#########################
#get /sauth/session/new
#########################
    describe "get /sauth/session/new" do
      
      it "should get /sauth/session/new" do
        get '/sauth/session/new'
        last_response.should be_ok
         end

      it "should return a form to post registration info to /sauth/session/new" do
        get '/sauth/session/new'
        last_response.body.should match %r{<form action="/sauth/session/new" method="post".*}
         end
    end

    describe "post /sauth/session/new" do
      before do
        @params = { 'login' => "login", "passwd" => "pass" }
      
      end

      it "Should use user is present" do
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "pass")
        post '/sauth/session/new', @params


      end

      it "Should redirect if the log and pass is prensent" do

        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post '/sauth/session/new', @params
        last_response.should be_redirect
      end

      it "Should redirect to the user page if the log and pass is prensent" do
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post '/sauth/session/new', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/'
      end

      context "Connexion is not OK" do

      it "Should go to get /sauth/session/new if the log and pass is not prensent" do
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "pass").and_return(false)
        post '/sauth/session/new', @params
        last_response.body.should match %r{<form action="/sauth/session/new" method="post".*}
      end

      it "Should go to get /sauth/session/new if the log is not given" do
        @params['login']="" 
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("", "pass").and_return(false)
        post '/sauth/session/new', @params
        last_response.body.should match %r{<form action="/sauth/session/new" method="post".*}
      end

      it "Should go to get /sauth/session/new if the pass is not given" do
        @params['passwd']=""
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "").and_return(false)
        post '/sauth/session/new', @params
        last_response.body.should match %r{<form action="/sauth/session/new" method="post".*}
      end

      end
    end

  end 
#########################
#App registration
#########################
  describe "App registration" do
#########################
#get /sauth/application/new
#########################
    describe "get /sauth/application/new" do
      it "should get /sauth/application/new" do
        get '/sauth/application/new'
        last_response.should be_ok
         end

      it "should return a form to post registration info to /sauth/application/new" do
        get '/sauth/application/new'
        last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}
         end
    end
#########################
#post /sauth/application/new
#########################
    describe "post /sauth/application/new" do
      before do
 	@params_create = { 'application' => {"name" => "appli", "url" => "http://www.julienriby.fr", "user_id" => 01}}
        @params = { 'name' => "appli", "url" => "http://www.julienriby.fr" }
        
        @a = Application.new
        @a.name = "appli"
        @a.url = "http://www.julienriby.fr"
        @a.user_id = "01"

        @u = User.new
        @u.id = "01"
        @u.login = "log"
        @u.passwd = "pass"


        User.stub(:find_by_login).and_return(@u)
        User.stub(:id).and_return("01")
      end

     it "should use create" do

        Application.stub(:create)
        Application.should_receive(:create).with(@params_create['application']).and_return(@a)
        post '/sauth/application/new', @params
      end
      it "should create appli with name set in browser" do

        Application.stub(:create)
        Application.should_receive(:create).with(@params_create['application']).and_return(@a)
         
        @a.name.should == @params['name']
        post '/sauth/application/new', @params
      end

      it "should create appli with url set in browser" do

        Application.stub(:create)
        Application.should_receive(:create).with(@params_create['application']).and_return(@a)
         
        @a.url.should == @params['url']
        post '/sauth/application/new', @params
      end

      it "should redirect to /" do
        Application.stub(:create)
        Application.should_receive(:create).with(@params_create['application']).and_return(@a)
        post '/sauth/application/new', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/'
      end
      context "Inscription app is not OK" do

        it "should render /sauth/application/new form if the name is not set" do
           
           @a.name = ""
           Application.stub(:create)
           Application.should_receive(:create).with(@params_create['application']).and_return(@a)
           post '/sauth/application/new', @params
           last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}
         end

        it "should render /sauth/application/new form if the url is not set" do
           
           @a.url = ""
           Application.stub(:create)
           Application.should_receive(:create).with(@params_create['application']).and_return(@a)
           post '/sauth/application/new', @params
           last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}
         end



         it "should render /sauth/application/new form if the name and the url are not set" do
           @a.name = ""
           @a.url = ""
           Application.stub(:create)
           Application.should_receive(:create).with(@params_create['application']).and_return(@a)
           post '/sauth/application/new', @params
           last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}
         end

        it "should render /sauth/application/new form if the url is invalid" do
           @a.url = "badurl"
           Application.stub(:create)
           Application.should_receive(:create).with(@params_create['application']).and_return(@a)
           post '/sauth/application/new', @params
           last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}
         end

        it "should render /sauth/application/new form if the name is invalid" do
           @a.name = "bad*name"
           Application.stub(:create)
           Application.should_receive(:create).with(@params_create['application']).and_return(@a)
           post '/sauth/application/new', @params
           last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}
         end

        it "should render the registration form if the login is already taken" do
           
           at = Application.new
           at.name = "taken"
           at.url = "http://www.julienriby.fr"
           at.user_id = "01"
           at.save

           @a.name = "taken"
           @a.url = "http://www.julien.fr"
           Application.stub(:create)
           Application.should_receive(:create).with(@params_create['application']).and_return(@a)
           post '/sauth/application/new', @params
           last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}

           at.destroy
         end

      end
    end
  end
  
  describe "Connexion Service" do

#########################
#get /sauth/admin
#########################
    describe "get /sauth/admin" do
      
      it "should get /sauth/admin" do
        get '/sauth/admin'
        last_response.should be_ok
         end
    end
  end

end
end

