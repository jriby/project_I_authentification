$: << File.dirname(__FILE__)

require 'sinatra'

set :port, 6002

use Rack::Session::Cookie, :key => 'rack.session',
                           :expire_after => 86400, #1 jour
                           :secret => 'super_user'

helpers do
  def current_user
    session["current_user_app2"]
  end
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
    #j'ai un cookie dans app
    erb :protected

  #j'ai pas de cookie ds app
  elsif params['secret'].nil?
    #Pas de secret donc ce n'est pas une rep de sauth
    redirect 'http://localhost:6666/app2/session/new?origin=/protected'
    elsif params['secret']=="jesuisauth" && !params['login'].nil?
      #L'auth est OK
      session["current_user_app2"] = params['login']
      erb :protected
      
      else
        #Pas de secret ou de param login -> je ne parle pas ac le bon sauth
        'Probleme avec le sauth !'
   end
end

