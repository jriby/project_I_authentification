require_relative 'spec_helper'
require 'user'



describe User do

#Une personne doit être valide si elle dispose d'un nom et d'un prénom. Le login d'une personne doit être unique sur toute la base.

before(:each) do
	@u=User.new()
end

context "init" do

  describe "With info missing" do

	it "should not be valid without a passwd" do
				
		@u.login = "jriby"
                @u.is_su = false	
		@u.should_not be_valid
	end
	
	it "should not be valid without a login" do

		@u.passwd = "pass"
                @u.is_su = false			
		@u.should_not be_valid
	end

        it "should not be valid if the passwd is empty" do
                @u.login = "jriby"
		@u.passwd = ""
                @u.is_su = false			
		@u.should_not be_valid
	end

	it "should be valid with a login a passwd and is_su" do

		@u.login = "jfunt"
		@u.passwd = "pass"
                @u.is_su = false
		@u.should be_valid

	end

  end

  describe "With info not missing" do
        it "should be valid with a login a passwd and without is_su fixed" do

		@u.login = "jfunt"
		@u.passwd = "pass"
		@u.should be_valid

	end
        
        it "should set is_su at false if it is not fixed" do

		@u.login = "jfunt"
		@u.passwd = "pass"
		@u.is_su.should == false

	end
  end

  describe "Unicity" do

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

  describe "Test passwd" do

    before(:each) do
      @u = User.new
      @u.login = "jriby"
    end

    it "Should call the encryption sha1" do

      Digest::SHA1.should_receive(:hexdigest).with("pass").and_return("ok")
      @u.passwd = "pass"
      @u.passwd.should == "\"ok\""
    end

    it "Should encrypt the pass" do

      @u.passwd = "pass"
      @u.passwd.should == "\"9d4e1e23bd5b727046a9e3b4b7db57bd8d6ee684\""
    end

  end

  describe "Test de create" do
    before do
        @params = { 'user' => {"login" => "jriby", "passwd" => "pass" }}
    end

    it "Should create the user" do
      @user = User.create(@params['user'])
      @user.should be_valid
      @user.destroy
    end
  end

end

end
