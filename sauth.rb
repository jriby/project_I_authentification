require 'sinatra'
$: << File.dirname(__FILE__)
require 'middleware/my_middleware'
require 'lib/person'
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



