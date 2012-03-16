require '../sauth'
require 'rack/test'

set :sessions, true

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
    describe "get /users/new" do
      it "should get /users/new" do
        get '/users/new'
        last_response.should be_ok
         end

      it "should return a form to post registration info to /users" do
        get '/users/new'
        last_response.body.should match %r{<form action="/users" method="post".*}
         end
    end
#########################
#post /users
#########################
    describe "post /users" do
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
        post '/users', @params
      end

      it "should create user with login set in browser" do

        User.stub(:create)
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
         
        @u.login.should == @params['login']
        post '/users', @params
      end

      it "should create user with passwd encypt set in browser" do

        User.stub(:create)
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
        @u.passwd.should == User.encrypt_password(@params['passwd'])
        post '/users', @params
      end


      it "should redirect to /session/new" do
        User.stub(:create)
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
        post '/users', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/session/new'
      end

      context "Registration is not OK" do

        it "should render the registration form if the login is not set" do
           
           @u.login = ""
           User.stub(:create)
           User.should_receive(:create).with(@params_create['user']).and_return(@u)
           post '/users', @params
           last_response.body.should match %r{<form action="/users" method="post".*}
         end

         it "should render the registration form if the pass is not set" do
           
           @u.passwd = ""
           User.stub(:create)
           User.should_receive(:create).with(@params_create['user']).and_return(@u)
           post '/users', @params
           last_response.body.should match %r{<form action="/users" method="post".*}
         end


        it "should render the registration form if the login and the pass are not set" do
           
           @u.login = ""
           @u.passwd = ""
           User.stub(:create)
           User.should_receive(:create).with(@params_create['user']).and_return(@u)
           post '/users', @params
           last_response.body.should match %r{<form action="/users" method="post".*}
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
           post '/users', @params
           last_response.body.should match %r{<form action="/users" method="post".*}

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
    describe "get /session/new" do
      
      it "should get /session/new" do
        get '/session/new'
        last_response.should be_ok
         end

      it "should return a form to post registration info to /sessions" do
        get '/session/new'
        last_response.body.should match %r{<form action="/sessions" method="post".*}
         end
    end

    describe "post /sessions" do
      before do
        @params = { 'login' => "login", "passwd" => "pass" }
      
      end

      it "Should use user is present" do
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "pass")
        post '/sessions', @params


      end

      it "Should redirect to the user page if the log and pass is prensent" do
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post '/sessions', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/'
      end

      context "Connexion is not OK" do

      it "Should return the connexion form if the log and pass is not prensent" do
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "pass").and_return(false)
        post '/sessions', @params
        last_response.body.should match %r{<form action="/sessions" method="post".*}
      end

      it "Should return the connexion form if the log is not given" do
        @params['login']="" 
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("", "pass").and_return(false)
        post '/sessions', @params
        last_response.body.should match %r{<form action="/sessions" method="post".*}
      end

      it "Should return the connexion form if the pass is not given" do
        @params['passwd']=""
        User.stub(:user_is_present)
        User.should_receive(:user_is_present).with("login", "").and_return(false)
        post '/sessions', @params
        last_response.body.should match %r{<form action="/sessions" method="post".*}
      end

      end
    end

  end 

#########################
#get /
#########################
    describe "get /" do
      
      it "should get /" do
        get '/'
        last_response.should be_ok
        last_request.path.should == '/'
         end

      it "should return the index page" do
        get '/'
        last_response.body.should match %r{<h1>Acceuil</h1>.*}
         end
    end

#########################
#get /users/:login
#########################
    describe "get /users" do

    before do 
       u = User.new
       u.login = "lolo"
       u.passwd = "pass"    
       u.save
       @params = { 'login' => "lolo", 'passwd' => "pass" }
       post "/sessions", @params
       follow_redirect!
       last_request.path.should == '/'
       last_request.env["rack.session"]["current_user"].should == "lolo"

    end
      
      it "should get /users" do

          u = User.new
          u.login = "lolo"
          u.passwd = "pass"    
          u.save
          @params = { 'login' => "lolo", 'passwd' => "pass" }
          post "/sessions", @params
          follow_redirect!
          last_request.path.should == '/'
          last_request.env["rack.session"]["current_user"].should == "lolo"

        get '/users/lolo'
        last_response.should be_ok
        last_request.path.should == '/users/lolo'
         end

      it "should return the user page" do
        get '/users/lolo'
        last_response.body.should match %r{<h1>Profil User</h1>.*}
      end

      context "without good current_user" do
        it "should return the acceuil" do
          get '/users/momo'
          last_response.should be_redirect
          follow_redirect!
          last_request.path.should == '/'
          last_response.body.should match %r{<h1>Acceuil</h1>.*}

        end
      end
      context "without current_user" do
        it "should return the acceuil" do
          get '/sessions/disconnect'
          get '/users/momo'
          last_request.env["rack.session"]["current_user"].should == nil
          last_response.should be_redirect
          follow_redirect!
          last_request.path.should == '/'
          last_response.body.should match %r{<h1>Acceuil</h1>.*}
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
      context "with current user" do
        it "should return a form to post registration info to /sauth/application/new" do
          u = User.new
          u.login = "log"
          u.passwd = "pass"    
          u.save
          @params = { 'login' => "log", 'passwd' => "pass" }
          post "/sessions", @params
          follow_redirect!
          last_request.path.should == '/'
          last_request.env["rack.session"]["current_user"].should == "log"
          
          get '/sauth/application/new'
          last_response.body.should match %r{<form action="/sauth/application/new" method="post".*}
          u.destroy
        end
      end
      context "without current user" do
        it "should return a form to post connexion info to /session/new" do
          get '/sauth/application/new'
          follow_redirect!
          last_response.should be_ok
          last_request.path.should == '/session/new'
          last_response.body.should match %r{<form action="/sessions" method="post".*}
        end
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

#########################
# Destruction d'appli
#########################
    describe "get /sauth/application/delete" do
      context "with current user" do
        it "should get /sauth/application/delete" do
          u = User.new
          u.login = "log"
          u.passwd = "pass"    
          u.save
          @params = { 'login' => "log", 'passwd' => "pass" }
          post "/sessions", @params
          follow_redirect!
          last_request.path.should == '/'
          last_request.env["rack.session"]["current_user"].should == "log"
          
          get '/sauth/application/delete'
          last_response.body.should match %r{}
          u.destroy
        end
      end
      context "without current user" do
        it "should go to index" do
          get '/sauth/application/delete'
          last_response.body.should match %r{<h1>Acceuil</h1>.*}
        end
      end
  end

#########################
# Portail d'admin users
#########################
  describe "get /sauth/admin" do
    it "should get /sauth/admin" do
       get '/sauth/admin'
       last_response.should be_ok
      end
    end


#########################
# Destruction de user
#########################


  describe "get /sauth/users/delete" do
    context "Without current user" do
      it "should redirect to /" do
        get '/sauth/users/delete'
        last_response.body.should match %r{<h1>Acceuil</h1>.*}
      end
    end
    context "With current user" do
      it "should delete the user if the curent user is admin" do
        u = User.new
        u.login = "admin"
        u.passwd = "pass"    
        u.save
        ud = User.new
        ud.id = 666
        ud.login = "utodel"
        ud.passwd = "pass"    
        ud.save

        @params = { 'login' => "admin", 'passwd' => "pass" }
        post "/sessions", @params
        follow_redirect!
        last_request.path.should == '/'
        last_request.env["rack.session"]["current_user"].should == "admin"
         
        @params_del = { "usr" => 666}
        udel = User.find_by_id(666)
        udel.should == ud
        get '/sauth/users/delete', @params_del
        udel = User.find_by_id(@params["usr"])
        udel.should == nil
        last_response.body.should match %r{<h1>Admin users</h1>.*}
        u.destroy

      end
      it "should go to index if the curent user is not admin" do
        u = User.new
        u.login = "lol"
        u.passwd = "pass"    
        u.save
        @params = { 'login' => "lol", 'passwd' => "pass" }
        post "/sessions", @params
        follow_redirect!
        last_request.path.should == '/'
        last_request.env["rack.session"]["current_user"].should == "lol"
        
        get '/sauth/users/delete'
        last_response.body.should match %r{<h1>Acceuil</h1>.*}        

        u.destroy
      end
    end
  end

end
end

