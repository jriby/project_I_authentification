require_relative 'spec_helper'
require 'application'
require 'user'
require 'utilisation'

describe Utilisation do
    before do
        @params_user = { 'user' => {"login" => "jriby", "passwd" => "pass" }}
	@params_app = { 'application' => {"name" => "appli", "url" => "http://www.julienriby.fr"}}
    end

  describe "With good infos" do

	it "should be valid with an application and a user" do
          @application = Application.create(@params_app['application'])
          @user = User.create(@params_user['user'])

          @params_util = { 'utilisation' => {"application" =>  @application, "user" => @user}}
          @utilisation = Utilisation.create(@params_util['utilisation'])

          @utilisation.should be_valid

          @utilisation.destroy
          @application.destroy
          @user.destroy
        end

  end

  describe "With info missing" do

	it "should not be valid without an application" do
          
          @user = User.create(@params_user['user'])

          @params_util = { 'utilisation' => {"user" => @user}}
          @utilisation = Utilisation.create(@params_util['utilisation'])

          @utilisation.should_not be_valid

          @user.destroy

        end
	it "should not be valid without a user" do
        
          @application = Application.create(@params_app['application'])

          @params_util = { 'utilisation' => {"application" =>  @application}}
          @utilisation = Utilisation.create(@params_util['utilisation'])

          @utilisation.should_not be_valid

          @application.destroy

        end

  end

end
