require_relative 'spec_helper'
require 'person'



describe Person do

#Une personne doit être valide si elle dispose d'un nom et d'un prénom. Le login d'une personne doit être unique sur toute la base.

before(:each) do
	@p=Person.new()
end

context "init" do
	it "should not be valid without a login" do
				
		@p.login = "jriby"	
		@p.should_not be_valid
	end
	
	it "should not be valid without a passwd" do

		@p.passwd = "pass"			
		@p.should_not be_valid
	end

	it "should be valid with a login and a passwd" do

		@p.login = "jfunt"
		@p.passwd = "pass"
		@p.should be_valid

	end


	it "should have a login unique" do
		
		@p1=Person.new()
		@p2=Person.new()
		@p1.login = "jgoin"
		@p1.passwd = "pass"	
		@p1.save
	
		@p2.login = "jgoin"
		@p2.passwd = "pass1"
		@p2.should_not be_valid
		#Person.all.each{|p| p.destroy}
		@p1.destroy

	end
def destroy
         unless new_record?
         connection.delete "DELETE FROM \#{self.class.quoted_table_name}\nWHERE \#{connection.quote_column_name(self.class.primary_key)} = \#{quoted_id}\n", "#{self.class.name} Destroy"
         end
 
         freeze
       end
end

end
