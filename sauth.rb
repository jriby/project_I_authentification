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
          error=params[:error]
          erb :"sauth/register", :locals => {:error => error}

end

get '/sauth/registerok' do
          
          erb :"sauth/registerok"

end

post'/sauth/register' do
	#Pas de login
	#if params[:login].empty?
        # puts "1"
        #  erb :"sauth/register"
	#Pas de pass
        #elsif params[:passwd].empty?
        #  puts "2"
        #  erb :"sauth/register"
        
        #Le login exise déjà ds la bdd
        #elsif Person.find_by_login(params[:login]).empty?
        #  puts "3"
        #  erb :"sauth/register"
        #else
          #On peut le login et le mdp dans la bdd
          #puts "4"
        p=Person.new()
	p.login = params[:login]
        p.passwd = params[:passwd]
        p.save
        
        if p.valid?
          redirect '/sauth/registerok'
        else
          errlog = p.errors.messages[:login]
          errpass = p.errors.messages[:pass]
          if errlog.nil?
          redirect "/sauth/register?error=Veuillez_entrer_un_mot_de_passe"
          elsif errlog.include?("has already been taken")
          redirect "/sauth/register?error=Login_deja_pris"
          elsif errlog.include?("can't be blank")
          redirect "/sauth/register?error=Veuillez_entrer_un_login"
          end
        #  "Registion OK !!!!!!!!!!"
         end

end

