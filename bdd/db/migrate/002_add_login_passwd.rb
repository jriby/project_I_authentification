class AddLoginPasswd < ActiveRecord::Migration
  def up
    add_column :people, :login, :string
    add_column :people, :passwd, :string
  end

  def down
    remove_column :people, :login
    remove_column :people, :passwd
    
  end
end
