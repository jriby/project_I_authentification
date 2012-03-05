require 'sinatra'
$: << File.dirname(__FILE__)
require 'middleware/my_middleware'
require 'bdd/lib/person'
require 'bdd/spec/spec_helper'

use RackCookieSession
use RackSession

helpers do 
  def current_user
    session["current_user"]
  end
end
