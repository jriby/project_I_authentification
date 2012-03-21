$: << File.dirname(__FILE__)
require 'sinatra'
require 'lib/user'
require 'lib/application'
require 'lib/utilisation'
require 'active_record'
require 'logger'
require 'bdd/database'

set :port, 6666

use Rack::Session::Cookie, :key => 'rack.session',
                           :expire_after => 86400, #1 jour
                           :secret => 'super_user'

set :logger , Logger.new('log/log_sessions.txt', 'weekly')

helpers do
  def current_user
    session["current_user"]
  end
end

  def disconnect
    session["current_user"] = nil
  end

#########################
# Portail d'inscription
#########################
get '/users/new' do

  erb :"users/new"

end

post'/users' do
  login = params['login']
  passwd = params['passwd']

  params = { 'user' => {"login" => login, "passwd" => passwd }}
  
  @u = User.create(params['user'])
  
  if @u.valid?
    redirect '/sessions/new'
  else
    @error = @u.errors.messages
    erb :"users/new"
  end
end


#########################
# Portail de connection
#########################
get '/sessions/new' do
          
          erb :"sessions/new"

end

post '/sessions' do

  if User.user_is_present(params['login'],params['passwd'])
    settings.logger.info("Connexion depuis le sauth de => "+params["login"])
    session["current_user"] = params['login']
    redirect "/"
  else
    @login = params['login']
    @error_con = "Les infos saisies sont incorrectes"   
    erb :"/sessions/new"
  end

end

#########################
# Deco
#########################
get '/sessions/disconnect' do
   disconnect
   redirect "/sessions/new"
end

#########################
# Index
#########################
get "/" do
  @user = current_user
  erb :"/index"
end

#########################
# Profile utilisateur
#########################
get "/users/:login" do

  if session["current_user"] == params[:login]
    @user = params[:login]
    erb :"users/profil"
  else
    403
  end

end



#########################
# Portail d'inscription d'appli
#########################
get '/applications/new' do

  if current_user
    erb :"/applications/new"
  else
    403
  end
end

post '/applications' do

  name = params['name']
  url = params['url']
  @u = User.find_by_login(current_user)
  uid = @u.id

  params = { 'application' => {"name" => name, "url" => url, "user_id" => uid}}

  @a = Application.create(params['application'])

  if @a.valid?
    @params_util = { 'utilisation' => {"application" =>  @a, "user" => @u}}
    @utilisation = Utilisation.create(@params_util['utilisation'])
    @user = current_user
    redirect "/users/#@user"
  else
    @error = @a.errors.messages
    erb :"/applications/new", :locals => {:user => current_user}
  end

end


#########################
# Destruction d'appli
#########################

get "/application/delete/:name" do

  if session["current_user"]
    
    app = Application.find_by_name(params["name"])

    if !app.nil?
      user = User.find_by_login(session["current_user"])
      if app.user_id != user.id
        403
      else
        Application.delete(app)
        @user = current_user
        redirect :"/users/#@user"
      end

    else
      404
   end

  else
    403

  end
end


#########################
# Destruction de user
#########################
get "/users/delete/:login" do

  @user = current_user
  usr = User.find_by_login(params["login"])

  if @user == "admin" 
    if usr != nil
      User.delete(usr)
      redirect :"/sauth/admin"
    else      
       404
     end

   else    
    403
  end


end

#########################
# Portail d'admin users
#########################
get "/sauth/admin" do
  @user = current_user

  if @user.nil? || @user != "admin"    
    403
  else
    erb :"/sauth/admin"
  end

end

#########################
# Error
#########################
error 403 do
   erb :forbidden
end
error 404 do
   erb :notfound
end


get '/:appli/sessions/new' do

  if Application.application_is_present(params[:appli])
  
    if current_user
      user = User.find_by_login(session["current_user"])
      appl = Application.find_by_name(params[:appli])
    
      if !Utilisation.utilisation_is_present(user, appl)
        settings.logger.info("Lutilisateur "+user.login+" sest inscrit a lapplication "+appl.name)
        params_util = { 'utilisation' => {"application" => appl, "user" => user}}
        Utilisation.create(params_util['utilisation'])
      end

      log = session["current_user"]
      url=appl.url+params[:origin]
      settings.logger.info("L'utilisateur "+user.login+" utilise l'application "+appl.name)
      redirect "#{url}?login=#{log}&secret=jesuisauth"
  
    elsif !params[:origin].nil?
      a = Application.find_by_name(params[:appli])
      @appli=params[:appli]
      @back_url=a.url+params[:origin]
      erb :"sessions/appli"
    else
      404
    end

  else
    404
  end
end

post '/:appli/sessions' do

  if User.user_is_present(params['login'],params['passwd'])

    user = User.find_by_login(params[:login])
    appl = Application.find_by_name(params[:appli])

    login=params["login"]
    session["current_user"]=login    

    if !Utilisation.utilisation_is_present(user, appl)
      settings.logger.info("L'utilisateur "+login+" utilise l'application "+params[:appli])
      params_util = { 'utilisation' => {"application" => appl, "user" => user}}
      Utilisation.create(params_util['utilisation'])
    end
    settings.logger.info("Lutilisateur "+login+" utilise lapplication "+params[:appli])
    redirect "#{params[:back_url]}?login=#{params[:login]}&secret=jesuisauth"
  else
    @login = params['login']
    @back_url=params[:back_url]
    @error_con = "Les infos saisies sont incorrectes" 
    @appli=params[:appli]
    erb :"sessions/appli"
  end
end
