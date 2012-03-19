require 'spec_helper'
require 'uri'
describe 'app' do

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
      last_response.body.should match %r{<h1>App cli 1</h1>.*}
     end
  end

#########################
#get /protected
#########################
  describe "get /protected" do
    
    context "Without session" do
      it "should redirect to the sauth" do      
          get '/protected'
          last_response.should be_redirect
          follow_redirect!
          last_request.url.should == 'http://localhost:6666/app1/session/new?origin=%2Fprotected'
      end
    end
    context "Reponse du sauth" do
    before do
              @params = { 'secret' => "jesuisauth", "login" => "log"}
    end
      it "should redirect to protected" do      
          get '/protected', @params
          last_response.body.should match %r{<h1>Page privee appli cli 1</h1>.*}
      end
      it "should set the session" do      
          get '/protected', @params
          last_request.env["rack.session"]["current_user_app1"].should == "log"
      end
    end

    context "With session" do
    before do
      @params = { 'secret' => "jesuisauth", "login" => "log"}
      get '/protected', @params
      last_request.env["rack.session"]["current_user_app1"].should == "log"
    end

      it "should get /protected" do
        get '/protected'
        last_response.should be_ok
        last_request.path.should == '/protected'
      end

      it "should return the private page" do
        get '/protected'
        last_response.body.should match %r{<h1>Page privee appli cli 1</h1>.*}
      end
    end

    context "Bad secret" do
      it "should have the message Probleme avec le sauth !" do      
        @params = { 'secret' => "jenesuispasauth", "login" => "log"}
        get '/protected', @params
        last_response.body.should match %r{Probleme avec le sauth !}
      end
    end

  end
end
