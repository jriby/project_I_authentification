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

get '/sauth/register' do

          erb :"sauth/register"

end

post'/sauth/register' do

  @u = User.create(params['user'])

  if @u
    redirect "/sauth/session/new"
  else
    erb :"sauth/register"
  end

end

get '/sauth/session/new' do
          
          erb :"/sauth/session/new"

end

post '/sauth/session/new' do
          
        

end



