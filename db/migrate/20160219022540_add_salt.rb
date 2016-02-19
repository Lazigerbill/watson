class AddSalt < ActiveRecord::Migration
  def change
    add_column :users, :salt, :string
    add_column :users, :crypted_password, :string
    remove_column :users, :password, :string
  end 
end
