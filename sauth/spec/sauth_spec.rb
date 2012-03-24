require 'spec_helper'


set :sessions, true

describe 'Authenticatin Service' do


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
        last_request.path.should == '/users/new'
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
        @params = { 'user' => {'login' => "login", "passwd" => "pass"}}
        @u = double("user", "login" => "login", "passwd" => "pass" )
        User.stub(:create){@u}
        @u.stub(:valid?){true}
      end

      it "should use create" do
        User.should_receive(:create).with("login" => "login", "passwd" => "pass").and_return(@u)
        post '/users', @params

      end

      it "should redirect to /sessions/new" do

        post '/users', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/sessions/new'
      end

      context "Registration is not OK" do

        it "should render the registration form if the user is not valid" do
           User.stub(:create){@u}
           @u.stub(:valid?){false}
           err = double()
           @u.stub(:errors){err}
           err.stub(:messages)
           post '/users', @params
           last_response.body.should match %r{<form action="/users" method="post".*}
         end

      end

    end
  end

#########################
#Connexion Service
#########################
  describe "Connexion Service" do

#########################
#get /sessions/new
#########################
    describe "get /sessions/new" do
      
      it "should get /sessions/new" do
        get '/sessions/new'
        last_response.should be_ok
         end

      it "should return a form to post registration info to /sessions" do
        get '/sessions/new'
        last_response.body.should match %r{<form action="/sessions" method="post".*}
         end
    end

    describe "post /sessions" do
      before do
        @params = { 'login' => "login", "passwd" => "pass" }
      
      end

      it "Should use user is present" do

        User.should_receive(:present?).with("login", "pass")
        post '/sessions', @params


      end

      it "Should redirect to the user page if the log and pass is present" do

        User.should_receive(:present?).with("login", "pass").and_return(true)
        post '/sessions', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/'
      end

      it "Should set a session" do
        User.should_receive(:present?).with("login", "pass").and_return(true)
        post "/sessions", @params
        last_request.env["rack.session"]["current_user"].should == "login"
 
      end

      context "Connexion is not OK" do

      it "Should return the connexion form if present? return false" do
        User.should_receive(:present?).with("login", "pass").and_return(false)
        post '/sessions', @params
        last_response.body.should match %r{<form action="/sessions" method="post".*}
      end
      end
    end

    describe "get /sessions/disconnect" do
      before do
        @params = { 'login' => "login", "passwd" => "pass" }
     
      end

      it "Should diconnect and redirect to /sessions/new" do
        User.should_receive(:present?).with("login", "pass").and_return(true)
        post "/sessions", @params

        get '/sessions/disconnect'
        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/sessions/new'
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
      @u = double("user", "id" => 01, "login" => "lolo", "passwd" => "pass" )
      User.stub(:find_by_login){@u}
    end
    
      context "with current_user" do
        before do
          User.stub(:present?).and_return(true)
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
        
        context "with bad current_user" do
          it "should have error 403" do
            get '/users/momo'
            last_response.status.should == 403
            last_response.body.should match %r{<h1>Forbiden</h1>.*}
          end
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
        User.stub(:present?){true}
        @params = { 'login' => "log", 'passwd' => "pass" }
        post "/sessions", @params
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
        @params = { 'application' => {'name' => "appli", "url" => "http://www.julienriby.fr" }}
       
        @a = double("application", :name => "appli", :url => "http://www.julienriby.fr", :user_id => "01")
        Application.stub(:create){@a}

        Utilisation.stub(:create)

        u = double("user", :id => 01, :login => "log", :passwd => "pass")
        User.stub(:find_by_login){u}

      end

      context "Inscription app is OK" do
      before do
        @a.stub(:valid?){true}
      end
        it "should use create" do
          Application.should_receive(:create).with({"name"=>"appli", "url"=>"http://www.julienriby.fr", "user_id"=>1})
          post '/applications', @params
        end

        it "should redirect to /users/:login" do
          post '/applications', @params
          last_response.should be_redirect
          follow_redirect!
          last_request.path.should == '/users/log'
        end

      end

      context "Inscription app is not OK" do
  
        it "should give /applications/new" do
           err = double()
           @a.stub(:errors){err}
           err.stub(:messages)
           @a.stub(:valid?){false}
           post '/applications', @params
           last_response.body.should match %r{<form action="/applications" method="post".*}
         end
      end
    end
  end
  
 #########################
#Destruction
#########################
  describe "Destroy app or user" do
#########################
# Destruction d'appli
#########################
    describe "delete /application/:name" do
    
    before do
      @u = double("user", "id" => 1, "login" => "log", "passwd" => "pass" )
      User.stub(:find_by_login){@u}

      @a = double("application", :id => 1, :name => "atodel", :url => "http://atodel.fr", :user_id => 1)
    end

      context "with current user" do
      before do
          User.stub(:present?){true}
          @params = { 'login' => "log", 'passwd' => "pass" }
          post "/sessions", @params

      end
        
       it "should use delete and redirect to /users/log" do
          Application.stub(:find_by_name){@a}
          Application.should_receive(:delete).with(@a)
          delete '/application/atodel'
          last_response.should be_redirect
          follow_redirect!
          last_request.path.should == '/users/log'
        end

      it "should have error 404 if the app doesn't exist" do
        Application.stub(:find_by_name){nil}
        delete '/application/apasexister'
        last_response.status.should == 404
        last_response.body.should match %r{<h1>Not Found</h1>.*}
        end
      end
      context "without current user" do
        it "should have error 403" do
        delete '/application/atodel'
        last_response.status.should == 403
        last_response.body.should match %r{<h1>Forbiden</h1>.*}
        end
      end
      context "without user admin of the app" do
        it "should have error 403" do
          @a = double("application", :id => 1, :name => "atodel", :url => "http://atodel.fr", :user_id => 2)
          post "/sessions", @params
          delete '/application/atodel'
          last_response.status.should == 403
          last_response.body.should match %r{<h1>Forbiden</h1>.*}
        end
      end
    end



#########################
# Destruction de user
#########################


  describe "delete /users/:login" do

    context "Without current user" do
      it "should have error 403" do
        delete '/users/lol'
        last_response.status.should == 403
        last_response.body.should match %r{<h1>Forbiden</h1>.*}
      end
    end

    context "With current user" do
    before do
      @u = double("user","id" => 1,"login" => "admin", "passwd" => "pass" )

      @ud = double("user","login" => "utodel", "passwd" => "pass" )
      User.stub(:find_by_login){@ud}

      User.stub(:present?){true}
      @params = { 'login' => "admin", 'passwd' => "pass" }
      post "/sessions", @params

    end

      it "should delete the user and redirect to admin page if the curent user is admin" do

        User.should_receive(:delete).with(@ud)
        delete '/users/utodel'

        last_response.should be_redirect
        follow_redirect!
        last_request.path.should == '/users/admin'

      end

      it "should have error 404 if the user to del doesn't exist" do

        User.stub(:find_by_login){nil}

        delete '/users/utodel'
        last_response.status.should == 404
        last_response.body.should match %r{<h1>Not Found</h1>.*}

      end
      it "should have error 403 if the curent user is not admin" do
        User.stub(:present?){true}
        @params = { 'login' => "noadmin", 'passwd' => "pass" }
        post "/sessions", @params
            
        delete '/users/utodel'
        last_response.status.should == 403
        last_response.body.should match %r{<h1>Forbiden</h1>.*}

      end
    end
  end
 

  end
 #########################
#Connexion Service with app
#########################
  describe "Connexion Service with app" do

#########################
#get /sessions/new/app/:appli
#########################
    describe "get /sessions/new/app/app1" do
      context "With good app" do
      before do
        Utilisation.stub(:create)
params = { 'application' => {"name" => "app1", "url" => "http://www.julienriby:6001", "user_id" => 01}}
        @application = Application.create(params['application'])
      end
      after do
        @application.destroy
      end
        it "should get /sessions/new/app/app1" do
          get '/sessions/new/app/app1?origin=/'
          last_response.should be_ok
        end

        it "should return a form to post registration info to /app1/sessions" do
          get '/sessions/new/app/app1?origin=/'
          last_response.body.should match %r{<form action="/sessions/app/app1" method="post".*}
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

            get '/sessions/new/app/app1?origin=/protected'
            last_response.should be_redirect
            follow_redirect!
            last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
          end

          it "Should use utilisation is present and redirect to the app if utilisation is present return true" do
 
            Utilisation.should_receive(:present?).with(@user, @application).and_return(true)
            get '/sessions/new/app/app1?origin=/protected'
            last_response.should be_redirect
            follow_redirect!
            last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
            end

          it "Should use utilisation is present and create Utilisation if utilisation is present return false" do
 
            Utilisation.should_receive(:present?).with(@user, @application).and_return(false)
            params_util = { 'utilisation' => {"application" => @application, "user" => @user}}
            Utilisation.should_receive(:create).with(params_util['utilisation'])
            get '/sessions/new/app/app1?origin=/protected'
            last_response.should be_redirect
            follow_redirect!
            last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
            end
        end
      
        context "With bad info" do
          it "should return 404 if app1 doesn't exist" do
            Application.should_receive(:present?).and_return(false)
            get '/sessions/new/app/app1?origin=/'
            last_response.status.should == 404
            last_response.body.should match %r{<h1>Not Found</h1>}
          end

          it "should return 404 if origin is not set" do
            get '/sessions/new/app/app1'
            last_response.status.should == 404
            last_response.body.should match %r{<h1>Not Found</h1>}
          end
        end
      end
    end

    describe "post /sessions/app/:appli" do
      before do
        Utilisation.stub(:create)
        @params = { 'login' => "login", "passwd" => "pass", 'back_url' => "http://www.julienriby:6001/protected" }
params = { 'application' => {"name" => "app1", "url" => "http://www.julienriby:6001", "user_id" => 01}}
        @application = Application.create(params['application'])
      end
      after do
        @application.destroy
      end

      it "Should use user is present" do

        User.should_receive(:present?).with("login", "pass")
        post '/sessions/app/app1', @params

      end

     it "Should use utilisation is present" do
        params_user = { 'user' => {"login" => "login", "passwd" => "pass" }}
        user = User.create(params_user['user'])
        Utilisation.should_receive(:present?).with(user, @application)
        post '/sessions/app/app1', @params
        user.destroy
      end

      it "Should redirect to the app if the log and pass is present" do
        Utilisation.should_receive(:present?).and_return(true)
        User.should_receive(:present?).with("login", "pass").and_return(true)
        post '/sessions/app/app1', @params
        last_response.should be_redirect
        follow_redirect!
        last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
      end

       it "Should use utilisation is present and create Utilisation if utilisation is present return false" do
         Utilisation.should_receive(:present?).and_return(false)
         User.should_receive(:present?).with("login", "pass").and_return(true)
         Utilisation.should_receive(:create)
         post '/sessions/app/app1', @params
         last_response.should be_redirect
         follow_redirect!
         last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
       end

      it "Should set a session" do
        Utilisation.should_receive(:present?).and_return(true)
        User.should_receive(:present?).with("login", "pass").and_return(true)
        post '/sessions/app/app1', @params
        last_request.env["rack.session"]["current_user"].should == "login"
 
      end

      context "Utilisation is present return false" do

        it "Should redirect to the page if the log and pass is present" do
          Utilisation.should_receive(:present?).and_return(false)
          User.should_receive(:present?).with("login", "pass").and_return(true)
          post '/sessions/app/app1', @params
          last_response.should be_redirect
          follow_redirect!
          last_request.url.should == 'http://www.julienriby:6001/protected?login=login&secret=jesuisauth'
        end



      end
      context "User is present return false" do

        it "Should return the connexion form if present? return false" do
          User.should_receive(:present?).with("login", "pass").and_return(false)
          post '/sessions/app/app1', @params
          last_response.body.should match %r{<h1>Portail de Connexion</h1>.*}
        end
      end
    end
  end
end
