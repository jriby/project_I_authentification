class AddLoginPasswdIssu < ActiveRecord::Migration
  def up
    add_column :users, :login, :string
    add_column :users, :passwd, :string
    add_column :users, :is_super_user, :boolean, :default => false
  end

  def down
    remove_column :users, :login
    remove_column :users, :passwd
    
  end
end
