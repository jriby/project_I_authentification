require 'sinatra'
$: << File.dirname(__FILE__)
require 'middleware/my_middleware'
require 'lib/user'
require 'lib/application'
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

          erb :"/sauth/application/new"

end

post'/sauth/application/new' do

name = params['name']
url = params['url']

params = { 'application' => {"name" => name, "url" => url }}

  @a = Application.create(params['application'])
  
  if @a.valid?
    redirect "/"
  else
    @error = @a.errors.messages
    erb :"/sauth/application/new"
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
  erb :"/index" , :locals => {:user => current_user}
end

get'/sessions/deco' do
   disconnect
   redirect "/sauth/session/new"
end

#########################
# Portail d'admin users
#########################
get "/sauth/admin" do
  erb :"/sauth/admin" , :locals => {:user => current_user}
end
