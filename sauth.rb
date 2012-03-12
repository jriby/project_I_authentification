$: << File.dirname(__FILE__)
require 'sinatra'
require 'middleware/my_middleware'
require 'lib/user'
require 'lib/application'
require 'lib/utilisation'
require 'spec/spec_helper'

use RackCookieSession
use RackSession

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
get '/sauth/register' do

          erb :"sauth/register"

end

post'/sauth/register' do

login = params['login']
passwd = params['passwd']

params = { 'user' => {"login" => login, "passwd" => passwd }}

  @u = User.create(params['user'])
  
  if @u.valid?
    redirect "/"
  else
    @error = @u.errors.messages
    erb :"sauth/register"
  end

end

#########################
# Portail d'inscription d'appli
#########################
get '/sauth/application/new' do

  if current_user
    erb :"/sauth/application/new", :locals => {:user => current_user}
  else
    erb :"/sauth/session/new"

  end
end

post'/sauth/application/new' do

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
    erb :"/sauth/application/new", :locals => {:user => current_user}
  end

end

#########################
# Destruction d'appli
#########################

get "/sauth/application/delete" do

  if session["current_user"]
    @login = session["current_user"]
    erb :"/sauth/application/delete"
  else

    redirect 'sauth/sessions/new'

  end
end


#########################
# Portail de connection
#########################
get '/sauth/session/new' do
          
          erb :"/sauth/session/new"

end

post '/sauth/session/new' do

  if User.user_is_present(params['login'],params['passwd'])
    session["current_user"] = params['login']
    redirect "/"
  else     
    @error_con = "Les infos saisies sont incorrectes"   
    erb :"/sauth/session/new"
  end

end

get "/" do
  @user = current_user
  erb :"/index"
end
get'/sessions/deco' do
   disconnect
   redirect "/sauth/session/new"
end

#########################
# Portail d'admin users
#########################
get "/sauth/admin" do
  @user = current_user
  erb :"/sauth/admin"

end
