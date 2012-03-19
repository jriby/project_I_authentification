$: << File.dirname(__FILE__)

require 'sinatra'

set :port, 6001

enable :sessions

helpers do
  def current_user
    session["current_user_app1"]
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
    redirect 'http://localhost:6666/app1/session/new?origin=/protected'
    elsif params['secret']=="jesuisauth" && !params['login'].nil?
      #L'auth est OK
      session["current_user_app1"] = params['login']
      erb :protected
      
      else
        #Pas de secret ou de param login -> je ne parle pas ac le bon sauth
        'Probleme avec le sauth !'
   end
end

