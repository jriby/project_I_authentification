$: << File.dirname(__FILE__)

require 'sinatra'

enable :sessions

helpers do
  def current_user
    session["current_user"]
  end
end

  def disconnect
    session["current_user"] = nil
  end


# Index
get '/' do
  erb :index
end
