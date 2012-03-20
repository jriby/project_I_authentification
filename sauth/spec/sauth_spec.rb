require '../sauth'
require 'rack/test'

set :sessions, true

describe 'Authenticatin Service' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

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
        #last_request.path.should == '/users/new'
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
        User.should_receive(:create).with(@params_create['user']).and_return(@u)
      end

      it "should use create" do
       
        post '/users', @params

      end

      it "should redirect to /session/new" do

   
        post '/users', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/session/new'
      end

      context "Registration is not OK" do

        it "should render the registration form if the login is not set" do
           
           @u.login = ""

           post '/users', @params
           last_response.body.should match %r{<form action="/users" method="post".*}
         end

         it "should render the registration form if the pass is not set" do
           
           @u.passwd = ""

           post '/users', @params
           last_response.body.should match %r{<form action="/users" method="post".*}
         end


        it "should render the registration form if the login and the pass are not set" do
           
           @u.login = ""
           @u.passwd = ""

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

        User.should_receive(:user_is_present).with("login", "pass")
        post '/sessions', @params


      end

      it "Should redirect to the user page if the log and pass is present" do

        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post '/sessions', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/'
      end

      it "Should set a session" do
        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post "/sessions", @params
        last_request.env["rack.session"]["current_user"].should == "login"
 
      end

      context "Connexion is not OK" do

      it "Should return the connexion form if user_is_present return false" do    
        User.should_receive(:user_is_present).with("login", "pass").and_return(false)
        post '/sessions', @params
        last_response.body.should match %r{<form action="/sessions" method="post".*}
      end


      end
    end

    describe "get /sessions/disconnect" do
      before do
        @params = { 'login' => "login", "passwd" => "pass" }
     
      end

      it "Should diconnect and redirect to /session/new" do
        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post "/sessions", @params
        last_request.env["rack.session"]["current_user"].should == "login"
        get '/sessions/disconnect'
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/session/new'
        last_request.env["rack.session"]["current_user"].should == nil
      end    
    end
  end 

  describe "Index and user pages" do
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
        last_response.body.should match %r{<h1>Acceuil du sauth</h1>.*}
         end
    end

#########################
#get /users/:login
#########################
    describe "get /users/:login" do

    before do 
       @u = User.new
       @u.login = "lolo"
       @u.passwd = "pass"    
       @u.save
    end    
    
    after do 
       @u.destroy
    end
      context "with current_user" do
        before do
          @params = { 'login' => "lolo", 'passwd' => "pass" }
          post "/sessions", @params

        end
        it "should get /users" do

          get '/users/lolo'
          last_response.should be_ok
          last_request.path.should == '/users/lolo'
         end

        it "should return the user page" do
          get '/users/lolo'
          last_response.body.should match %r{<h1>Profil User</h1>.*}
        end
      end

      context "without good current_user" do
        it "should have error 403" do
          get '/users/momo'
          last_response.status.should == 403       
          last_response.body.should match %r{<h1>Forbiden</h1>.*}

        end
      end
      context "without current_user" do
        it "should have error 403" do
          get '/users/momo'
          last_response.status.should == 403       
          last_response.body.should match %r{<h1>Forbiden</h1>.*}
        end
      end

    end
  end


#########################
#App registration
#########################
  describe "App registration" do
#########################
#get /applications/new
#########################
    describe "get /applications/new" do
      context "with current user" do
      before do
        @u = User.new
        @u.login = "log"
        @u.passwd = "pass"    
        @u.save
        @params = { 'login' => "log", 'passwd' => "pass" }
        post "/sessions", @params
      end
      after do
        @u.destroy
      end

       it "should get /applications/new" do
                  
          get '/applications/new'
          last_response.should be_ok
          last_request.path.should == '/applications/new'
          
        end

        it "should return a form to post registration info to /applications" do
                  
          get '/applications/new'
          last_response.body.should match %r{<form action="/applications" method="post".*}
     
        end

      end
      context "without current user" do
        it "should have error 403" do
          get '/applications/new'
          last_response.status.should == 403       
          last_response.body.should match %r{<h1>Forbiden</h1>.*}
        end
      end

    end

#########################
#post /applications
#########################
    describe "post /applications" do
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

      context "Inscription app is OK" do
      
        before do
          Application.should_receive(:create).with(@params_create['application']).and_return(@a)
        end

        it "should use create" do
           
          post '/applications', @params

        end

        it "should redirect to /users/:login" do
          @params_con = { 'login' => "log", 'passwd' => "pass" }
          post "/sessions", @params_con
 
          post '/applications', @params
          last_response.should be_redirect
          follow_redirect!
          last_request.path.should == '/users/log'
        end

      end

      context "Inscription app is not OK" do
        before do
          Application.should_receive(:create).with(@params_create['application']).and_return(@a)
        end
        it "should give /applications/new form if the name is not set" do
           
           @a.name = ""          
           post '/applications', @params
           last_response.body.should match %r{<form action="/applications" method="post".*}
         end

        it "should give /applications/new form if the url is not set" do
           
           @a.url = ""
           post '/applications', @params
           last_response.body.should match %r{<form action="/applications" method="post".*}
         end



         it "should give /applications/new form if the name and the url are not set" do
           @a.name = ""
           @a.url = ""
           post '/applications', @params
           last_response.body.should match %r{<form action="/applications" method="post".*}
         end

        it "should give /applications/new form if the url is invalid" do
           @a.url = "badurl"
           post '/applications', @params
           last_response.body.should match %r{<form action="/applications" method="post".*}
         end

        it "should give /applications/new form if the name is invalid" do
           @a.name = "bad*name"
           post '/applications', @params
           last_response.body.should match %r{<form action="/applications" method="post".*}
         end

        it "should give /applications/new form if the name is already taken" do
           
           at = Application.new
           at.name = "taken"
           at.url = "http://www.julienriby.fr"
           at.user_id = "01"
           at.save

           @a.name = "taken"
           @a.url = "http://www.julien.fr"
           post '/applications', @params
           last_response.body.should match %r{<form action="/applications" method="post".*}

           at.destroy
         end

      end
    end
  end
  

#########################
# Destruction d'appli
#########################
    describe "get /application/delete/:name" do
    
    before do
      @u = User.new
      @u.login = "log"
      @u.passwd = "pass"    
      @u.save
      @a = Application.new
      @a.id = 1
      @a.name = "atodel"
      @a.url = "http://atodel.fr"
      @a.user_id = @u.id    
      @a.save
    end
    after do
      @u.destroy
      @a.destroy
    end
      context "with current user" do
      before do
          @params = { 'login' => "log", 'passwd' => "pass" }
          post "/sessions", @params

      end
        
       it "should use delete in @a and redirect to /users/log" do
          get '/application/delete/atodel'
          #Application.should_receive(:delete)
          adel = Application.find_by_name("utodel")
          adel.should == nil
          last_response.should be_redirect
          follow_redirect!
          last_request.path.should == '/users/log'
        end     

      it "should have error 404 if the app doesn't exist" do
          get '/application/delete/apasexister'
        last_response.status.should == 404
        last_response.body.should match %r{<h1>Not Found</h1>.*} 
        end     
      end
      context "without current user" do
        it "should have error 403" do
          get '/application/delete/atodel'
        last_response.status.should == 403       
        last_response.body.should match %r{<h1>Forbiden</h1>.*}
        end
      end
      context "without user admin of the app" do
        it "should have error 403" do
          @u2 = User.new
          @u2.login = "toto"
          @u2.passwd = "pass"    
          @u2.save
          @params = { 'login' => "toto", 'passwd' => "pass" }
          post "/sessions", @params
          get '/application/delete/atodel'
          last_response.status.should == 403       
          last_response.body.should match %r{<h1>Forbiden</h1>.*}
  
          @u2.destroy
        end
      end

  end




#########################
# Destruction de user
#########################


  describe "delete /users/:login" do

    context "Without current user" do
      it "should have error 403" do
        get '/users/delete/lol'
        last_response.status.should == 403       
        last_response.body.should match %r{<h1>Forbiden</h1>.*}
      end
    end

    context "With current user" do
      it "should delete the user if the curent user is admin" do
        u = User.new
        u.login = "admin"
        u.passwd = "pass"    
        u.save
        ud = User.new
        ud.login = "utodel"
        ud.passwd = "pass"    
        ud.save

        @params = { 'login' => "admin", 'passwd' => "pass" }
        post "/sessions", @params
         
        get '/users/delete/utodel'
        udel = User.find_by_login("utodel")
        udel.should == nil
        last_response.should be_redirect
        follow_redirect!
        last_response.body.should match %r{<h1>Admin Page</h1>.*}

      end

      it "should have error 404 if the user to del doesn't exist" do
        u = User.new
        u.login = "admin"
        u.passwd = "pass"    
        u.save

        @params = { 'login' => "admin", 'passwd' => "pass" }
        post "/sessions", @params
         
        get '/users/delete/utodel'
        last_response.status.should == 404
        last_response.body.should match %r{<h1>Not Found</h1>.*}  

      end
      it "should have error 403 if the curent user is not admin" do
        u = User.new
        u.login = "lol"
        u.passwd = "pass"    
        u.save
        @params = { 'login' => "lol", 'passwd' => "pass" }
        post "/sessions", @params
        
        
        get '/users/delete/utodel'
        last_response.status.should == 403
        last_response.body.should match %r{<h1>Forbiden</h1>.*}      

        u.destroy
      end
    end
  end

#########################
# Portail d'admin users
#########################
  describe "get /sauth/admin" do
    context "With current user admin"
    before do
      @u = User.new
      @u.login = "admin"
      @u.passwd = "pass"    
      @u.save
      @params = { 'login' => "admin", 'passwd' => "pass" }
      post "/sessions", @params
    end
    after do
      get '/sessions/disconnect'
      @u.destroy
    end
      it "should get /sauth/admin" do
        get '/sauth/admin'
        last_response.should be_ok
        last_request.path.should == '/sauth/admin'
      end
      it "should return the admin page" do
        get '/sauth/admin'
        last_response.body.should match %r{<h1>Admin Page</h1>.*}   
      end

    context "Without current user admin"

      it "should have error 403 if the current user is not the admin" do
        u = User.new
        u.login = "pasadmin"
        u.passwd = "pass"    
        u.save
        @params = { 'login' => "pasadmin", 'passwd' => "pass" }
        post "/sessions", @params

        get '/sauth/admin'
        last_response.status.should == 403       
        last_response.body.should match %r{<h1>Forbiden</h1>.*}

        get '/sessions/disconnect'
        u.destroy
      end

      it "should have error 403 if there is no user" do
        get '/sessions/disconnect'
        get '/sauth/admin'
        last_response.status.should == 403       
        last_response.body.should match %r{<h1>Forbiden</h1>.*}
      end
    end
 #########################
#Connexion Service with app
#########################
  describe "Connexion Service with app" do

#########################
#get /app/session/new
#########################
    describe "get /app1/session/new" do
      context "With good app" do
      before do
	params = { 'application' => {"name" => "app1", "url" => "http://www.julienriby:6001", "user_id" => 01}}
        @application = Application.create(params['application'])
      end
      after do
        @application.destroy
      end
        it "should get /app1/session/new" do
          get '/app1/session/new?origin=/'
          last_response.should be_ok
        end

        it "should return a form to post registration info to /app1/sessions" do
          get '/app1/session/new?origin=/'
          last_response.body.should match %r{<form action="/app1/sessions" method="post".*}
        end

        context "With current user" do
        before do
          params_user = { 'user' => {"login" => "login", "passwd" => "pass" }}
          @user = User.create(params_user['user'])
          @params = { 'login' => "login", 'passwd' => "pass" }
          post "/sessions", @params
        end
        after do
          @user.destroy
        end

          it "Should redirect to the app" do

            get '/app1/session/new?origin=/protected'
            last_response.should be_redirect
            follow_redirect!
            last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
          end

          it "Should use utilisation is present and redirect to the app if utilisation is present return true" do
 
            Utilisation.should_receive(:utilisation_is_present).with(@user, @application).and_return(true)
            get '/app1/session/new?origin=/protected'
            last_response.should be_redirect
            follow_redirect!
            last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
            end

          it "Should use utilisation is present and create Utilisation if utilisation is present return false" do
 
            Utilisation.should_receive(:utilisation_is_present).with(@user, @application).and_return(false)
            params_util = { 'utilisation' => {"application" => @application, "user" => @user}}
            Utilisation.should_receive(:create).with(params_util['utilisation'])
            get '/app1/session/new?origin=/protected'
            last_response.should be_redirect
            follow_redirect!
            last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
            end
        end
      
        context "With bad info" do
          it "should return 404 if app1 doesn't exist" do
            get '/appdontexist/session/new?origin=/'
            last_response.status.should == 404
            last_response.body.should match %r{<h1>Not Found</h1>}
          end

          it "should return 404 if origin is not set" do
            get '/app1/session/new'
            last_response.status.should == 404
            last_response.body.should match %r{<h1>Not Found</h1>}
          end
        end
      end
    end

    describe "post /:appli/sessions" do
      before do
        @params = { 'login' => "login", "passwd" => "pass", 'back_url' => "http://www.julienriby:6001/protected" }
	params = { 'application' => {"name" => "app1", "url" => "http://www.julienriby:6001", "user_id" => 01}}
        @application = Application.create(params['application'])
      end
      after do
        @application.destroy
      end

      it "Should use user is present" do

        User.should_receive(:user_is_present).with("login", "pass")
        post '/app1/sessions', @params

      end

     it "Should use utilisation is present" do
        params_user = { 'user' => {"login" => "login", "passwd" => "pass" }}
        user = User.create(params_user['user'])
        Utilisation.should_receive(:utilisation_is_present).with(user, @application)
        post '/app1/sessions', @params
        user.destroy
      end

      it "Should redirect to the app if the log and pass is present" do
        Utilisation.should_receive(:utilisation_is_present).and_return(true)
        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post '/app1/sessions', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
      end

       it "Should use utilisation is present and create Utilisation if utilisation is present return false" do
         Utilisation.should_receive(:utilisation_is_present).and_return(false)
         User.should_receive(:user_is_present).with("login", "pass").and_return(true)
         Utilisation.should_receive(:create)
         post '/app1/sessions', @params
         last_response.should be_redirect
         follow_redirect!
         last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
       end

      it "Should set a session" do
        Utilisation.should_receive(:utilisation_is_present).and_return(true)
        User.should_receive(:user_is_present).with("login", "pass").and_return(true)
        post '/app1/sessions', @params
        last_request.env["rack.session"]["current_user"].should == "login"
 
      end

      context "Utilisation is present return false" do

        it "Should redirect to the page if the log and pass is present" do
          Utilisation.should_receive(:utilisation_is_present).and_return(false)
          User.should_receive(:user_is_present).with("login", "pass").and_return(true)
          post '/app1/sessions', @params
          last_response.should be_redirect
          follow_redirect!
          last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
        end



      end
      context "User is present return false" do

        it "Should return the connexion form if user_is_present return false" do    
          User.should_receive(:user_is_present).with("login", "pass").and_return(false)
          post '/app1/sessions', @params
          last_response.body.should match %r{<h1>Portail de Connexion</h1>.*}
        end
      end
    end
  end
end

