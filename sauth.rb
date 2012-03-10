require 'sinatra'
$: << File.dirname(__FILE__)
require 'middleware/my_middleware'
require 'lib/user'
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
    redirect "/sauth/session/new"
  else
    @error = @u.errors.messages
    erb :"sauth/register"
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
    redirect "/index"
  else     
    @error_con = "Les infos saisies sont incorrectes"   
    erb :"/sauth/session/new"
  end

end

get "/index" do
  erb :"/index"
end

get'/sessions/deco' do
   disconnect
   redirect "/sauth/session/new"
end


