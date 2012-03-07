require '../sauth'
require 'rack/test'
require 'test/unit'

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
      get '/sauth/register'   
      last_response.status.should == 200
    end
  

      context "The login and the pass are ok" do

	it "should create the user with login and pass in the bdd " do
          post '/sauth/register', :login => 'jriby', :passwd => 'pass'
          last_response.status.should == 302
          last_response.headers["Location"].should == "http://example.org/sauth/registerok"
          User.all.each{|u| u.destroy}
        end
      end
      context "The login and the pass are not ok" do
	it "should redirect at /sauth/register if the login are ever used" do
          u=User.new()
	  u.login = "login"
	  u.passwd = "pass"	
          u.save
          post '/sauth/register', :login => 'login', :passwd => 'coucou'
          last_response.status.should == 302
          last_response.headers["Location"].should == "http://example.org/sauth/register?error=Login_deja_pris"
	  u.destroy
        end
	it "should redirect at /sauth/register if the pass is empty" do
          post '/sauth/register', :login => 'lol', :passwd => ''
          last_response.status.should == 302
          last_response.headers["Location"].should == "http://example.org/sauth/register?error=Veuillez_entrer_un_mot_de_passe"
        end
	it "should redirect at /sauth/register if the login empty" do
          post '/sauth/register', :login => '', :passwd => 'lol'
          last_response.status.should == 302
          last_response.headers["Location"].should == "http://example.org/sauth/register?error=Veuillez_entrer_un_login"
        end


      end
  end 
end

