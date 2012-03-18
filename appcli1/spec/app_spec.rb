require 'spec_helper'

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

end
