$: << File.dirname(__FILE__)

require 'sinatra'

set :port, 6001

use Rack::Session::Cookie, :key => 'rack.session.app1',
                           :expire_after => 86400, #1 jour
                           :secret => 'hey'

helpers do
  def current_user
    session["current_user_app1"]
  end
end

before '/protected' do
      redirect 'http://sauth:6666/sessions/new/app/app1?origin=/protected' if !current_user && !params['secret']
end
#########################
# Index
#########################
get '/' do
  erb :index
end


#########################
# Protected
#########################
get '/protected' do

  if current_user
    erb :protected

  elsif params['secret']=="jesuisauth" && params['login']
      session["current_user_app1"] = params['login']
      erb :protected
      
    else
        'Probleme avec le sauth !'
   end
end

