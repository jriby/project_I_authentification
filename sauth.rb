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

#########################
# Deco
#########################
get '/sessions/disconnect' do
   disconnect
   redirect "/session/new"
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
  redirect "/"
  end

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
        @user = current_user
        redirect :"/"

      else
        Application.delete(app)
        @user = current_user
        redirect :"/users/#@user"
      end

    else
      @user = current_user  
      redirect :"/"
   end

  else

    redirect "/"

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
       
       redirect :"/"
     end

   else
    
    redirect :"/"
  end


end

#########################
# Portail d'admin users
#########################
get "/sauth/admin" do
  @user = current_user

  if @user.nil? || @user != "admin"
    @error = 'Page Interdite'
    redirect :"/"
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




