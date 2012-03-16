$: << File.dirname(__FILE__)
require 'sinatra'
require 'lib/user'
require 'lib/application'
require 'lib/utilisation'
require 'spec/spec_helper'

enable :sessions

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
    redirect '/session/new'
  else
    @error = @u.errors.messages
    erb :"users/new"
  end

end


#########################
# Portail de connection
#########################
get '/session/new' do
          
          erb :"session/new"

end

post '/sessions' do

  if User.user_is_present(params['login'],params['passwd'])
    session["current_user"] = params['login']
    redirect "/"
  else     
    @error_con = "Les infos saisies sont incorrectes"   
    erb :"/session/new"
  end

end

get "/" do
  @user = current_user
  erb :"/index"
end

get '/sessions/disconnect' do
   disconnect
   redirect "/session/new"
end

#########################
# Portail d'inscription d'appli
#########################
get '/applications/new' do

  if current_user
    erb :"/applications/new"
  else
    redirect "/session/new"

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
    redirect "/"
  else
    @error = @a.errors.messages
    erb :"/applications/new", :locals => {:user => current_user}
  end

end

#########################
# Profile utilisateur
#########################
get "/users/:login" do

  if session["current_user"] == params[:login]
  @user = params[:login]
  erb :"users/profil"
  else
  redirect "/"
  end

end


#########################
# Destruction de user
#########################

delete "/users/:login" do

  if session["current_user"] == "admin" 
   u = User.find_by_login(params["login"])
   u.destroy
   erb :"/sauth/admin"

   else
    @error = 'Pas les droits pour supprimer un user'
    @user = current_user
    erb :"/index"
  end

end

#########################
# Portail d'admin users
#########################
get "/sauth/admin" do
  @user = current_user
  erb :"/sauth/admin"

end


#########################
# Destruction d'appli
#########################

get "/sauth/application/delete" do

  if session["current_user"]
    
    app = Application.find_by_id(params["app"])

    if !app.nil?
      user = User.find_by_login(session["current_user"])
      if app.user_id != user.id
        @user = current_user
        @error = "Vous n'avez pas les droits : cette application n'est pas a vous"
        erb :"/index"

      else
        uti = Utilisation.where(:application_id => app.id)
       
        uti.each do |u|
          u.destroy
        end

        app.destroy
        @user = current_user
        erb :"/index"
      end

    else
      @error = "Cette application n'existe pas"
      @user = current_user  
      erb :"/index"
   end

  else

    erb :"/index"

  end
end




