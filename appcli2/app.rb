$: << File.dirname(__FILE__)

require 'sinatra'

set :port, 6002

use Rack::Session::Cookie, :key => 'rack.session.app2',
                           :expire_after => 86400, #1 jour
                           :secret => 'hey'

helpers do
  def current_user
    session["current_user_app2"]
  end
end

before '/protected' do
      redirect 'http://sauth:6666/sessions/new/app/app2?origin=/protected' if !current_user && !params['secret']
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

  elsif params['secret']=="jesuisauth" && !params['login'].nil?
      session["current_user_app2"] = params['login']
      erb :protected
      
      else
        'Probleme avec le sauth !'
   end
end

