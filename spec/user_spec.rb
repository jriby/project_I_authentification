require_relative 'spec_helper'
require 'user'



describe User do

#Une personne doit être valide si elle dispose d'un nom et d'un prénom. Le login d'une personne doit être unique sur toute la base.

before(:each) do
	@u=User.new()
end

context "init" do
	it "should not be valid without a login" do
				
		@u.login = "jriby"	
		@u.should_not be_valid
	end
	
	it "should not be valid without a passwd" do

		@u.passwd = "pass"			
		@u.should_not be_valid
	end

	it "should be valid with a login and a passwd" do

		@u.login = "jfunt"
		@u.passwd = "pass"
		@u.should be_valid

	end


	it "should have a login unique" do
		
		@u1=User.new()
		@u2=User.new()
		@u1.login = "jgoin"
		@u1.passwd = "pass"	
		@u1.save
	
		@u2.login = "jgoin"
		@u2.passwd = "pass1"
		@u2.valid?
		@u2.errors.messages[:login].include?("has already been taken").should be_true
		#User.all.each{|m| m.destroy}
		@u1.destroy

	end

end

end
